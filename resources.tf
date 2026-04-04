
###  ---  Default Application  ---  ###
module "httpd" {
  source = "./modules/httpd"
  depends_on = [kubernetes_namespace.n8n]

  name   = "httpd-server"
  namespace = "default"
  replicas  = 1
  image = "virtapp/apache:7f6c4bf4-3-6"
  service_port = 8080
  service_type = "ClusterIP"
}

module "weaviate" {
  source = "./modules/weaviate"
  depends_on = [module.httpd]
}

module "local-exec" {
  source = "./modules/local-exec"
  depends_on = [module.weaviate]
}


