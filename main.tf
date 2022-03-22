
locals {
  tmp_dir = "${path.cwd}/.tmp/vsi-bootstrap"
  dest_values_yaml = "${local.tmp_dir}/values.yaml"
  dest_cloud_init = "${local.tmp_dir}/cloud-init.yaml"
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

  clis = ["yq"]
}

resource local_file values_yaml {
  filename = local.dest_values_yaml

  content = yamlencode({
    config = {
      gitops_config_repo_url = var.gitops_repo_url
      gitops_config_username = var.git_username
      gitops_config_token = nonsensitive(var.git_token)
      gitops_bootstrap_path = var.bootstrap_path
      gitops_bootstrap_branch = var.bootstrap_branch
      ingress_subdomain = var.ingress_subdomain
      sealed_secret_cert = var.sealed_secret_cert
      sealed_secret_private_key = nonsensitive(var.sealed_secret_private_key)
    }
    repo = {
      url = "https://github.com/cloud-native-toolkit/terraform-vsi-argocd-bootstrap"
      path = "terraform"
      branch = var.bootstrap_branch
    }
  })
}

resource null_resource setup_init_script {
  depends_on = [local_file.values_yaml]

  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-init-script.sh ${local.dest_values_yaml} ${local.dest_cloud_init}"

    environment = {
      BIN_DIR = module.setup_clis.bin_dir
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
  init_script          = file(local.dest_cloud_init)
  create_public_ip     = true
  tags                 = []
  label                = var.label
  allow_deprecated_image = var.allow_deprecated_image
  security_group_rules = local.security_group_rules
  allow_ssh_from       = var.allow_ssh_from
  ssh_key_id           = module.vpcssh.id
}
