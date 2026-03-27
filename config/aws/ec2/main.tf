
resource "kubernetes_manifest" "provider_aws" {
  manifest = {
    apiVersion = "pkg.crossplane.io/v1"
    kind       = "Provider"
    metadata = {
      name = "provider-aws"
    }
    spec = {
      package = "xpkg.upbound.io/crossplane-contrib/provider-aws:v0.48.0"
    }
  }

  depends_on = [helm_release.crossplane]
}

resource "kubernetes_secret" "aws_creds" {
  metadata {
    name      = "aws-creds"
    namespace = "crossplane-system"
  }

  data = {
    creds = base64encode(<<EOF
[default]
aws_access_key_id = ${var.aws_access_key_id}
aws_secret_access_key = ${var.aws_secret_access_key}
EOF
    )
  }
}

resource "kubernetes_manifest" "provider_config" {
  manifest = {
    apiVersion = "aws.crossplane.io/v1beta1"
    kind       = "ProviderConfig"
    metadata = {
      name = "aws-default"
    }
    spec = {
      credentials = {
        source = "Secret"
        secretRef = {
          namespace = "crossplane-system"
          name      = kubernetes_secret.aws_creds.metadata[0].name
          key       = "creds"
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.provider_aws]
}

resource "kubernetes_manifest" "ec2_instance" {
  manifest = {
    apiVersion = "ec2.aws.crossplane.io/v1beta1"
    kind       = "Instance"
    metadata = {
      name = "example-ec2"
    }
    spec = {
      forProvider = {
        region        = "us-east-1"
        instanceType  = "t3.micro"
        imageId       = "ami-0c02fb55956c7d316"
        subnetId      = var.subnet_id
        securityGroupIds = [var.security_group_id]
        keyName       = var.key_name
        tags = [
          {
            key   = "Name"
            value = "crossplane-ec2"
          }
        ]
      }
      providerConfigRef = {
        name = "aws-default"
      }
    }
  }

  depends_on = [kubernetes_manifest.provider_config]
}
