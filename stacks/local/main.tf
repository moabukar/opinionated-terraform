module "vpc" {
  source                = "../../modules/vpc"
  name                  = "${var.name_prefix}-vpc"
  cidr                  = "10.30.0.0/16"
  nat_gateway_count     = 0
  create_public_subnets = true
  enable_flow_logs      = false
  tags = {
    Name        = "${var.name_prefix}-vpc"
    Environment = "local"
    Owner       = "platform@coderco.dev"
    ManagedBy   = "Terraform"
    Repo        = "coderco/infra"
    GitCommit   = "local"
    CostCenter  = "ENG-PLATFORM"
  }
}

# module "ecr" {
#   source = "../../modules/ecr"
#   name   = "coderco/local/app"
#   tags = {
#     Name        = "coderco-local-ecr"
#     Environment = "local"
#     Owner       = "platform@coderco.dev"
#     ManagedBy   = "Terraform"
#     Repo        = "coderco/infra"
#     GitCommit   = "local"
#     CostCenter  = "ENG-PLATFORM"
#   }
# }
