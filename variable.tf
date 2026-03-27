
variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig for the target cluster"
  default     = "~/.kube/config"
}

variable "charts_path" {
  default     = "./modules"
  description = "The charts full path"
}




