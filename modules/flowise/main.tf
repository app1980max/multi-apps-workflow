
resource "helm_release" "flowise" {
  name             = "flowise"
  repository       = "https://cowboysysop.github.io/charts/"
  chart            = "flowise"
  version          = "6.0.0"
  namespace        = "flowise-ai"
  create_namespace = true

  # Forces recreate if something exists
  force_update = true

  atomic           = false
  cleanup_on_fail  = true
  timeout          = 600

  set {
    name  = "image.tag"
    value = "3.0.3"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "env.WEAVIATE_URL"
    value = "http://weaviate.weaviate.svc.cluster.local:80"
  }

  set {
    name  = "env.WEAVIATE_API_KEY"
    value = "dev-key-123"
  }

  # 🔹 Auth (IMPORTANT)
  set {
    name  = "env.FLOWISE_USERNAME"
    value = "admin"
  }

  set {
    name  = "env.FLOWISE_PASSWORD"
    value = "admin123"
  }
  
}
