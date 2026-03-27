
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
}

resource "kubernetes_manifest" "gke_cluster" {
  manifest = {
    apiVersion = "container.gcp.crossplane.io/v1beta1"
    kind       = "Cluster"
    metadata = {
      name = "example-gke"
    }
    spec = {
      forProvider = {
        project = var.gcp_project
        location = var.gcp_region  # region or zone
        initialNodeCount = 1
        nodeConfig = {
          machineType = "e2-medium"
          diskSizeGb  = 50
        }
        network = var.gcp_network
        subnetwork = var.gcp_subnetwork
        addonsConfig = {
          httpLoadBalancing = {}
          cloudRunConfig    = {}
        }
      }

      providerConfigRef = {
        name = "gcp-default"
      }

      writeConnectionSecretToRef = {
        namespace = "default"
        name      = "gke-cluster-conn"
      }
    }
  }
}

variable "gcp_project" {}
variable "gcp_region" {
  default = "us-central1"
}
variable "gcp_network" {
  default = "default"
}
variable "gcp_subnetwork" {
  default = "default"
}
variable "gcp_sa_key_file" {}
