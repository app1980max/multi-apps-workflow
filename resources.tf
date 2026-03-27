
###  ---  Default Template  ---  ###
module "minio" {
  source = "./modules/minio"
  depends_on = [kubernetes_namespace.crossplane]
}

module "crossplane" {
  source = "./modules/crossplane"
  depends_on = [module.minio]
}

module "argo" {
  source = "./modules/argo"
  depends_on = [module.crossplane]
}
