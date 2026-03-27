
resource "kubernetes_manifest" "provider_gcp" {
  manifest = {
    apiVersion = "pkg.crossplane.io/v1"
    kind       = "Provider"
    metadata = {
      name = "provider-gcp"
    }
    spec = {
      package = "xpkg.upbound.io/crossplane-contrib/provider-gcp:v0.25.0"
    }
  }
}

resource "kubernetes_secret" "gcp_creds" {
  metadata {
    name      = "gcp-creds"
    namespace = "crossplane-system"
  }

  data = {
    key = base64encode(file(var.gcp_sa_key_file))
  }
}

resource "kubernetes_manifest" "provider_config_gcp" {
  manifest = {
    apiVersion = "gcp.crossplane.io/v1beta1"
    kind       = "ProviderConfig"
    metadata = {
      name = "gcp-default"
    }
    spec = {
      credentials = {
        source = "Secret"
        secretRef = {
          namespace = "crossplane-system"
          name      = kubernetes_secret.gcp_creds.metadata[0].name
          key       = "key"
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.provider_gcp]
}

variable "gcp_sa_key_file" {
  description = "Path to GCP Service Account JSON"
}

variable "gcp_project" {}
variable "gcp_zone" {
  default = "us-central1-a"
}
variable "gcp_network" {
  default = "default"
}
