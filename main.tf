
locals {
  tmp_dir = "${path.cwd}/.tmp"
  dest_init_script_dir = "${local.tmp_dir}/argocd-bootstrap/scripts"
  dest_init_script_file = "${local.dest_init_script_dir}/init-argocd.sh"
  subnets = [ var.vpc_subnets[0] ]
  terraform_yaml = "${local.tmp_dir}/argocd-bootstrap/argocd-bootstrap.yaml"
  subnet_count = 1
  security_group_rules = [{
    name = "ingress-everything"
    direction = "inbound"
    remote = "0.0.0.0/0"
  }, {
    name = "egress-everything"
    direction = "outbound"
    remote = "0.0.0.0/0"
  }]
}

resource null_resource print_rg {
  provisioner "local-exec" {
    command = "echo 'Resource group: ${var.resource_group_name}'"
  }
}

data ibm_resource_group rg {
  depends_on = [null_resource.print_rg]

  name = var.resource_group_name
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

  clis = ["helm"]
}

resource null_resource generate_toolkit_install_yaml {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-argocd-bootstrap-yaml.sh ${local.terraform_yaml}"

    environment = {
      BIN_DIR = module.setup_clis.bin_dir
      GITOPS_CONFIG_REPO_URL = var.gitops_repo_url
      GITOPS_CONFIG_USERNAME = var.git_username
      GITOPS_CONFIG_TOKEN = nonsensitive(var.git_token)
      GITOPS_BOOTSTRAP_PATH = var.bootstrap_path
      GITOPS_BOOTSTRAP_BRANCH = var.bootstrap_branch
      TERRAFORM_REPO_BRANCH = var.terraform_repo_branch
      INGRESS_SUBDOMAIN = var.ingress_subdomain
      SEALED_SECRET_CERT = var.sealed_secret_cert
      SEALED_SECRET_PRIVATE_KEY = nonsensitive(var.sealed_secret_private_key)
    }
  }
}

resource null_resource setup_init_script {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-init-script.sh ${local.dest_init_script_dir}"

    environment = {
      IBMCLOUD_API_KEY = var.ibmcloud_api_key
      SERVER_URL = var.server_url
    }
  }
}

module "vpcssh" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc-ssh.git"

  resource_group_name = var.resource_group_name
  name_prefix         = var.vpc_name
  public_key          = ""
  private_key         = ""
  label               = "argocd-sshkey"
}

module "vsi-instance" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc-vsi.git?ref=v1.11.0"

  resource_group_id    = data.ibm_resource_group.rg.id
  region               = var.region
  ibmcloud_api_key     = var.ibmcloud_api_key
  vpc_name             = var.vpc_name
  vpc_subnet_count     = local.subnet_count
  vpc_subnets          = local.subnets
  image_name           = var.image_name
  profile_name         = var.profile_name
  kms_key_crn          = var.kms_key_crn
  kms_enabled          = var.kms_enabled
  init_script          = file("${path.module}/scripts/init-script.sh")
  create_public_ip     = true
  tags                 = []
  label                = var.label
  allow_deprecated_image = var.allow_deprecated_image
  security_group_rules = local.security_group_rules
  allow_ssh_from       = "0.0.0.0/0"
  ssh_key_id           = module.vpcssh.id
}

resource "null_resource" "deploy_argocd" {
  depends_on = [null_resource.setup_init_script]

  triggers = {
    type        = "ssh"
    user        = "root"
    password    = ""
    private_key = module.vpcssh.private_key
    host        = module.vsi-instance.public_ips[0]
  }

  connection {
    type        = self.triggers.type
    user        = self.triggers.user
    password    = self.triggers.password
    private_key = self.triggers.private_key
    host        = self.triggers.host
  }

  provisioner "file" {
    source      = local.dest_init_script_dir
    destination = "/tmp"
  }

  provisioner "file" {
    source      = local.terraform_yaml
    destination = "/tmp/argocd-bootstrap.yaml"
  }

  provisioner "remote-exec" {
    inline     = [
      "chmod +x /tmp/*.sh",
      "/tmp/init-argocd.sh"
    ]
  }

  provisioner "remote-exec" {
    when       = destroy
    inline     = [
      "chmod +x /tmp/*.sh",
      "/tmp/destroy-argocd.sh"
    ]
  }
}
