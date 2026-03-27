
resource "helm_release" "n8n" {
  namespace  = "n8n"
  create_namespace = true
  name       = "n8n"
  chart = "${var.charts_path}/n8n/"

  atomic           = false
  cleanup_on_fail  = true
  timeout          = 600
 
}
