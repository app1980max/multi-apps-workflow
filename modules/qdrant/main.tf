
resource "helm_release" "qdrant" {
  name       = "qdrant"
  namespace  = "qdrant"
  repository = "https://qdrant.github.io/qdrant-helm/"
  chart      = "qdrant"

  create_namespace = true

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.size"
    value = "10Gi"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "replicaCount"
    value = 1
  }
}
