
resource "kubernetes_manifest" "s3_bucket" {
  manifest = {
    apiVersion = "s3.aws.crossplane.io/v1beta1"
    kind       = "Bucket"
    metadata = {
      name = "example-bucket"
    }
    spec = {
      forProvider = {
        region = var.region

        # Optional settings
        acl   = "private"
        versioningConfiguration = {
          status = "Enabled"
        }

        tags = [
          {
            key   = "Name"
            value = "crossplane-s3"
          },
          {
            key   = "Environment"
            value = "dev"
          }
        ]
      }

      providerConfigRef = {
        name = "aws-default"
      }

      writeConnectionSecretToRef = {
        namespace = "default"
        name      = "example-s3-secret"
      }
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}
