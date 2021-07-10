
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
