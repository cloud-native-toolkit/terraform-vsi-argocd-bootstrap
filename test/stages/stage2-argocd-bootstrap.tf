module "argocd-bootstrap" {
  source = "./module"

  ibmcloud_api_key    = var.ibmcloud_api_key
  region              = var.region
  resource_group_name = module.resource_group.name
  cluster_type        = module.dev_cluster.platform.type_code
  ingress_subdomain   = module.dev_cluster.platform.ingress
  server_url          = module.dev_cluster.platform.server_url
  olm_namespace       = module.dev_software_olm.olm_namespace
  operator_namespace  = module.dev_software_olm.target_namespace
  gitops_repo_url     = module.gitops.config_repo_url
  git_username        = module.gitops.config_username
  git_token           = module.gitops.config_token
  bootstrap_path      = module.gitops.bootstrap_path
  bootstrap_branch    = module.gitops.bootstrap_branch
  vpc_name            = module.subnets.vpc_name
  vpc_subnet_count    = module.subnets.count
  vpc_subnets         = module.subnets.subnets
  sealed_secret_cert  = module.cert.cert
  sealed_secret_private_key = module.cert.private_key
  terraform_repo_branch = var.terraform_repo_branch
  allow_ssh_from = "0.0.0.0/0"
}

resource local_file ssh_key {
  filename = "${path.cwd}/.ssh/id_ssh_key"

  content = nonsensitive(module.argocd-bootstrap.ssh_private_key)
}

resource local_file public_ip {
  filename = "${path.cwd}/.public_ip"

  content = module.argocd-bootstrap.public_ips[0]
}
