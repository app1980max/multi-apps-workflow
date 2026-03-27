
resource "helm_release" "weaviate" {
  name       = "weaviate"
  repository = "https://weaviate.github.io/weaviate-helm"
  chart      = "weaviate"
  version    = "17.5.1"
  namespace  = "weaviate"
  create_namespace = true

  atomic           = false
  cleanup_on_fail  = true
  timeout          = 600


  set {
  name  = "service.type"
  value = "ClusterIP"
  }

  set {
    name  = "grpcService.type"
    value = "ClusterIP"
  }

  set {
    name  = "authentication.anonymous_access.enabled"
    value = "true"
  }

  set {
    name  = "env.DEFAULT_VECTORIZER_MODULE"
    value = "none"
  }

  set {
    name  = "env.ENABLE_MODULES"
    value = ""
  }

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.size"
    value = "10Gi"
  }

  set {
    name  = "logLevel"
    value = "info"
  }
}
