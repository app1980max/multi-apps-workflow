
###  ---  Default Template  ---  ###
module "weaviate" {
  source = "./modules/weaviate"
  depends_on = [kubernetes_namespace.n8n]
}

module "n8n" {
  source = "./modules/n8n"
  depends_on = [module.weaviate]
}

module "flowise" {
  source = "./modules/flowise"
  depends_on = [module.n8n]
}
