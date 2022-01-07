variable "server_url" {
  type        = string
  description = "The url of the OCP server for logging in"
}

variable "login_token" {
  type        = string
  description = "The token used to log into the server"
  sensitive   = true
}

variable "skip_login" {
  type        = string
  description = "Flag to indicate that the login should be skipped (i.e. already logged in)"
  default     = false
}

variable "gitops_config_repo_url" {
  type        = string
}

variable "gitops_config_username" {
  type        = string
}

variable "gitops_config_token" {
  type        = string
  sensitive   = true
}

variable "gitops_bootstrap_path" {
  type        = string
}

variable "ingress_subdomain" {
  default = ""
}

variable "sealed_secret_cert" {
  default = ""
}

variable "sealed_secret_private_key" {
  default = ""
}
