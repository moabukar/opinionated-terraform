provider "aws" {
  region                      = var.region
  access_key                  = "local"
  secret_key                  = "local"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3         = var.localstack_endpoint
    dynamodb   = var.localstack_endpoint
    sts        = var.localstack_endpoint
    iam        = var.localstack_endpoint
    ecr        = var.localstack_endpoint
    ec2        = var.localstack_endpoint
    logs       = var.localstack_endpoint
    cloudwatch = var.localstack_endpoint
    kms        = var.localstack_endpoint
    # rds/eks are not used in local stack
  }

  default_tags {
    tags = {
      Owner       = "platform@coderco.dev"
      ManagedBy   = "Terraform"
      Repo        = "coderco/infra"
      GitCommit   = "local"
      CostCenter  = "ENG-PLATFORM"
      Environment = "local"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
