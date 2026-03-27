
###  ---  Default Template  ---  ###
module "weaviate" {
  source = "./modules/weaviate"
  depends_on = [kubernetes_namespace.n8n]
}

module "flowise" {
  source = "./modules/flowise"
  depends_on = [module.weaviate]
}



