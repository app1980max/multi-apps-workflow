
# Create a Kubernetes secret for API keys
resource "kubernetes_secret" "weaviate_api_keys" {
  metadata {
    name      = "weaviate-api-keys"
    namespace = var.namespace
  }

  data = {
    # Map each user to their API key
    # The Helm chart expects a JSON string of {user: key}
    "apiKeys.json" = jsonencode(
      { for idx, user in var.api_users : user => var.api_keys[idx] }
    )
  }

  type = "Opaque"
}

# Helm release
resource "helm_release" "weaviate" {
  name             = var.release_name
  repository       = "https://weaviate.github.io/weaviate-helm"
  chart            = "weaviate"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  force_update     = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 600

  # Service type
  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "grpcService.type"
    value = "ClusterIP"
  }

  # Authentication: use API key from secret
  set {
    name  = "authentication.anonymous_access.enabled"
    value = "false"
  }

  set {
    name  = "authentication.apiKey.valueFromSecret"
    value = kubernetes_secret.weaviate_api_keys.metadata[0].name
  }

  # Modules
  set {
    name  = "env.DEFAULT_VECTORIZER_MODULE"
    value = var.vectorizer_module
  }

  set {
    name  = "env.ENABLE_MODULES"
    value = ""
  }

  # Persistence
  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.size"
    value = var.storage_size
  }

  # Logging
  set {
    name  = "logLevel"
    value = "info"
  }
}
