module "vpc" {
  source                = "../../modules/vpc"
  name                  = var.name_prefix
  cidr                  = var.cidr
  nat_gateway_count     = 1
  create_public_subnets = true
  tags = {
    Name        = "${var.name_prefix}-vpc"
    Environment = "dev"
    Owner       = "platform@coderco.dev"
    ManagedBy   = "Terraform"
    Repo        = "coderco/infra"
    GitCommit   = "unknown"
    CostCenter  = "ENG-PLATFORM"
  }
}

# module "ecr" {
#   source = "../../modules/ecr"
#   name   = "coderco/dev/app"
#   tags = {
#     Name        = "coderco-dev-ecr"
#     Environment = "dev"
#     Owner       = "platform@coderco.dev"
#     ManagedBy   = "Terraform"
#     Repo        = "coderco/infra"
#     GitCommit   = "unknown"
#     CostCenter  = "ENG-PLATFORM"
#   }
# }
