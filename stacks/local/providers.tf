provider "aws" {
  region                      = var.region
  access_key                  = "local"
  secret_key                  = "local"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true

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
  }

  default_tags {
    tags = {
      Name        = "stacks-local"
      Environment = "local"
      Owner       = "platform@coderco.dev"
      CostCenter  = "ENG-PLATFORM"
      ManagedBy   = "Terraform"
      Repo        = "coderco/terraform-aws-mono"
      GitCommit   = ""
    }
  }
}
