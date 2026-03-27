
resource "kubernetes_secret" "gcp_creds" {
  metadata {
    name      = "gcp-creds"
    namespace = "crossplane-system"
  }

  data = {
    key = base64encode(file(var.gcp_sa_key_file))
  }
}

variable "gcp_sa_key_file" {
  description = "Path to GCP Service Account JSON"
}

esource "kubernetes_manifest" "provider_config_gcp" {
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
}

resource "kubernetes_manifest" "gcs_bucket" {
  manifest = {
    apiVersion = "storage.gcp.crossplane.io/v1beta1"
    kind       = "Bucket"
    metadata = {
      name = "example-gcs-bucket"
    }
    spec = {
      forProvider = {
        location = var.gcp_region
        project  = var.gcp_project
        storageClass = "STANDARD"
        versioning = {
          enabled = true
        }
        labels = {
          environment = "dev"
          team        = "platform"
        }
      }

      providerConfigRef = {
        name = "gcp-default"
      }

      writeConnectionSecretToRef = {
        namespace = "default"
        name      = "gcs-bucket-conn"
      }
    }
  }

  depends_on = [kubernetes_manifest.provider_config_gcp]
}
