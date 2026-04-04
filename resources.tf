
###  ---  Default Application  ---  ###
module "weaviate" {
  source = "./modules/weaviate"
  depends_on = [kubernetes_namespace.n8n]
}

module "local-exec" {
  source = "./modules/local-exec"
  depends_on = [module.weaviate]
}

module "chroma" {
  source = "./modules/chroma"
  depends_on = [module.local-exec]
}

module "httpd" {
  source = "./modules/httpd"
  depends_on = [module.chroma]

  name   = "httpd-server"
  namespace = "default"
  replicas  = 1
  image = "virtapp/apache:7f6c4bf4-3-6"
  service_port = 8080
  service_type = "ClusterIP"
}
