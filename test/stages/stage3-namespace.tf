module "gitops_namespace" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-namespace"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  name = var.namespace
}

resource null_resource print_namespace {
  provisioner "local-exec" {
    command = "echo '${module.gitops_namespace.name}' > .namespace"
  }
}
