
variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig for the target cluster"
  default     = "~/.kube/config"
}

variable "crossplane_namespace" {
  type = string
}

variable "crossplane_version" {
  type = string
}

variable "crossplane_replicas" {
  type = number
}

variable "crossplane_metrics_enabled" {
  type = bool
}



