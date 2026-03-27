
resource "aws_iam_role" "lambda_exec" {
  name = "crossplane-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "kubernetes_manifest" "lambda_function" {
  manifest = {
    apiVersion = "lambda.aws.crossplane.io/v1alpha1"
    kind       = "Function"
    metadata = {
      name = "example-lambda"
    }
    spec = {
      forProvider = {
        functionName = "example-lambda"
        role         = aws_iam_role.lambda_exec.arn
        handler      = "index.handler"
        runtime      = "nodejs18.x"
        timeout      = 10

        code = {
          s3Bucket = var.lambda_code_s3_bucket
          s3Key    = var.lambda_code_s3_key
        }

        environment = {
          variables = {
            ENV = "dev"
          }
        }

        tags = {
          environment = "dev"
          team        = "platform"
        }
      }

      providerConfigRef = {
        name = "aws-default"
      }

      writeConnectionSecretToRef = {
        namespace = "default"
        name      = "lambda-function-conn"
      }
    }
  }
}

variable "lambda_code_s3_bucket" {}
variable "lambda_code_s3_key" {}
