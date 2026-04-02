
resource "kubernetes_namespace" "n8n" {
  metadata {
    name = "n8n"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  lifecycle {
    ignore_changes = all
  }
}   
