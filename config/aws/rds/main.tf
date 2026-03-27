
resource "kubernetes_manifest" "rds_instance" {
  manifest = {
    apiVersion = "rds.aws.crossplane.io/v1beta1"
    kind       = "DBInstance"
    metadata = {
      name = "example-rds"
    }
    spec = {
      forProvider = {
        region             = var.region
        dbInstanceClass    = "db.t3.micro"
        engine             = "postgres"
        engineVersion      = "15.3"
        allocatedStorage   = 20
        dbName             = "appdb"
        masterUsername     = "admin"
        publiclyAccessible = false
        skipFinalSnapshot  = true

        dbSubnetGroupName = "example-db-subnet-group"

        vpcSecurityGroupIds = [
          var.security_group_id
        ]

        tags = [
          {
            key   = "Name"
            value = "crossplane-rds"
          }
        ]
      }

      writeConnectionSecretToRef = {
        namespace = "default"
        name      = "example-rds-conn"
      }

      providerConfigRef = {
        name = "aws-default"
      }
    }
  }

  depends_on = [
    kubernetes_manifest.rds_subnet_group
  ]
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}
