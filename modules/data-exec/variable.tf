variable "namespace" {
  type        = string
  description = "Kubernetes namespace where Weaviate is deployed"
}

variable "api_keys" {
  type        = list(string)
  description = "List of API keys for Weaviate authentication"
}

variable "helm_release_name" {
  type        = string
  description = "The name of the helm_release to depend on"
}
