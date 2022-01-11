module "vpc" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc.git"

  resource_group_id   = module.resource_group.id
  resource_group_name = module.resource_group.name
  region              = var.region
  name                = var.vpc_name
  provision           = false
  base_security_group_name = var.base_security_group_name
}
