
output "argocd_namespace" {
  description = "The namespace where the ArgoCD instance has been provisioned"
  value       = "openshift-gitops"
  depends_on = [module.vsi-instance]
}

output "argocd_service_account" {
  description = "The namespace where the ArgoCD instance has been provisioned"
  value       = "argocd-cluster-argocd-application-controller"
  depends_on = [module.vsi-instance]
}

output "sealed_secrets_cert" {
  value = var.sealed_secret_cert
  depends_on = [module.vsi-instance]
}

output "ssh_private_key" {
  value = module.vpcssh.private_key
}

output "ssh_public_key" {
  value = module.vpcssh.public_key
}

output "ssh_id" {
  value = module.vpcssh.id
}

output "public_ips" {
  description = "The public ips of the instances"
  value       = module.vsi-instance.public_ips
}

output "private_ips" {
  value = module.vsi-instance.private_ips
  description = "The private ips of the instances"
}
