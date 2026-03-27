
resource "kubernetes_namespace" "crossplane" {
metadata {
name = "crossplane-system"
labels = {
"app.kubernetes.io/managed-by" = "terraform"
  }
 }
}
