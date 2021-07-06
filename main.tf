
locals {
  tmp_dir = "${path.cwd}/.tmp"
  source_init_script_file = "${path.module}/scripts/init-argocd.sh"
  dest_init_script_file = "${local.tmp_dir}/scripts/init-argocd.sh"
}

resource null_resource setup_init_script {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-init-script.sh ${local.source_init_script_file} ${local.dest_init_script_file}"

    environment = {
      IBMCLOUD_API_KEY = var.ibmcloud_api_key
      SERVER_URL = var.server_url
      CONFIG_REPO_URL = var.gitops_repo_url
      CONFIG_USERNAME = var.git_username
      CONFIG_TOKEN = var.git_token
      BOOTSTRAP_PATH = var.bootstrap_path
    }
  }
}

data local_file init_script {
  depends_on = [null_resource.setup_init_script]

  filename = local.dest_init_script_file
}

module "vsi-instance" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc-vsi.git?ref=v1.7.1"

  resource_group_id    = var.resource_group_id
  region               = var.region
  ibmcloud_api_key     = var.ibmcloud_api_key
  vpc_name             = var.vpc_name
  vpc_subnet_count     = var.vpc_subnet_count
  vpc_subnets          = var.vpc_subnets
  image_name           = var.image_name
  profile_name         = var.profile_name
  kms_key_crn          = var.kms_key_crn
  kms_enabled          = var.kms_enabled
  init_script          = data.local_file.init_script.content
  create_public_ip     = false
  tags                 = []
  label                = var.label
  allow_deprecated_image = var.allow_deprecated_image
  acl_rules            = []
}
