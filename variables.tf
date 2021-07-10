variable "resource_group_name" {
  type        = string
  description = "The name of the IBM Cloud resource group where the VPC has been provisioned."
}

variable "region" {
  type        = string
  description = "The IBM Cloud region where the cluster will be/has been installed."
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud api token"
}

variable "vpc_name" {
  type        = string
  description = "The name of the vpc instance"
}

variable "label" {
  type        = string
  description = "The label for the server instance"
  default     = "server"
}

variable "image_name" {
  type        = string
  description = "The name of the image to use for the virtual server"
  default     = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

variable "vpc_subnet_count" {
  type        = number
  description = "Number of vpc subnets"
}

variable "vpc_subnets" {
  type        = list(object({
    label = string
    id    = string
    zone  = string
  }))
  description = "List of subnets with labels"
}

variable "profile_name" {
  type        = string
  description = "Instance profile to use for the bastion instance"
  default     = "cx2-2x4"
}

variable "kms_enabled" {
  type        = bool
  description = "Flag indicating that the volumes should be encrypted using a KMS."
  default     = false
}

variable "kms_key_crn" {
  type        = string
  description = "The crn of the root key in the kms instance. Required if kms_enabled is true"
  default     = ""
}

variable "cluster_config_file" {
  type        = string
  description = "Cluster config file for Kubernetes cluster."
}

variable "cluster_type" {
  type        = string
  description = "The type of cluster (openshift or kubernetes)"
}

variable "olm_namespace" {
  type        = string
  description = "Namespace where olm is installed"
}

variable "operator_namespace" {
  type        = string
  description = "Namespace where operators will be installed"
}

variable "ingress_subdomain" {
  type        = string
  description = "The subdomain for ingresses in the cluster"
  default     = ""
}

variable "gitops_repo_url" {
  type        = string
  description = "The GitOps repo url"
}

variable "git_username" {
  type        = string
  description = "The username used to access the GitOps repo"
}

variable "git_token" {
  type        = string
  description = "The token used to access the GitOps repo"
  //  sensitive   = true
}

variable "bootstrap_path" {
  type        = string
  description = "The path to the bootstrap config for ArgoCD"
}

variable "allow_deprecated_image" {
  type        = bool
  description = "Flag indicating that deprecated images should be allowed for use in the Virtual Server instance. If the value is `false` and the image is deprecated then the module will fail to provision"
  default     = true
}

variable "server_url" {
  type        = string
  description = "The url of the OCP cluster where ArgoCd will be deployed"
}
