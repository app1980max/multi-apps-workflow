
resource "kubernetes_manifest" "eks_cluster" {
  manifest = {
    apiVersion = "eks.aws.crossplane.io/v1beta1"
    kind       = "Cluster"
    metadata = {
      name = "example-eks"
    }
    spec = {
      forProvider = {
        region = var.region

        # Cluster properties
        roleArn = var.eks_role_arn
        version = "1.28"

        resourcesVpcConfig = {
          subnetIds = var.subnet_ids
          endpointPublicAccess = true
        }

        tags = [
          { key = "Name", value = "crossplane-eks" }
        ]
      }

      providerConfigRef = {
        name = "aws-default"
      }

      # Stores kubeconfig / connection info
      writeConnectionSecretToRef = {
        namespace = "default"
        name      = "example-eks-conn"
      }
    }
  }
}

resource "kubernetes_manifest" "eks_nodegroup" {
  manifest = {
    apiVersion = "eks.aws.crossplane.io/v1beta1"
    kind       = "NodeGroup"
    metadata = {
      name = "example-eks-ng"
    }
    spec = {
      forProvider = {
        clusterName = "example-eks"
        nodeRoleArn = var.eks_node_role_arn
        scalingConfig = {
          desiredSize = 2
          maxSize     = 3
          minSize     = 1
        }
        instanceTypes = ["t3.medium"]
        subnets       = var.subnet_ids
        tags = [
          { key = "Name", value = "crossplane-eks-ng" }
        ]
      }
      providerConfigRef = {
        name = "aws-default"
      }
    }
  }

  depends_on = [kubernetes_manifest.eks_cluster]
}

variable "region" {
  default = "us-east-1"
}

variable "eks_role_arn" {}
variable "eks_node_role_arn" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
