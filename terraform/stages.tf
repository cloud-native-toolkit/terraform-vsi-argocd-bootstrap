module "cluster" {
  source = "github.com/cloud-native-toolkit/terraform-ocp-login.git?ref=v1.2.0"

  server_url  = var.server_url
  login_token = var.login_token
  skip        = var.skip_login
  ingress_subdomain = var.ingress_subdomain
}

module "dev_software_olm" {
  source = "github.com/cloud-native-toolkit/terraform-k8s-olm.git?ref=v1.3.2"

  cluster_config_file      = module.cluster.config_file_path
  cluster_version          = ""
  cluster_type             = module.cluster.platform.type_code
  olm_version              = "0.15.1"
}

module "argocd-bootstrap" {
  source = "github.com/cloud-native-toolkit/terraform-tools-argocd-bootstrap.git?ref=v1.4.4"

  cluster_type        = module.cluster.platform.type_code
  ingress_subdomain   = module.cluster.platform.ingress
  cluster_config_file = module.cluster.config_file_path
  olm_namespace       = module.dev_software_olm.olm_namespace
  operator_namespace  = module.dev_software_olm.target_namespace
  gitops_repo_url     = var.gitops_config_repo_url
  git_username        = var.gitops_config_username
  git_token           = var.gitops_config_token
  bootstrap_path      = var.gitops_bootstrap_path
  sealed_secret_cert  = var.sealed_secret_cert
  sealed_secret_private_key = var.sealed_secret_private_key
}
