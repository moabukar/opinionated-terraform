module "vpc" {
  source          = "../../modules/vpc"
  name            = "dev"
  cidr            = var.vpc_cidr
  public_subnets  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  nat_gateways    = 1
  tags            = { Environment = "dev", Name = "dev", GitCommit = "" }
}

# module "ecr" {
#   source = "../../modules/ecr"
#   name   = "dev/app"
#   tags   = { Environment = "dev", Name = "dev-app", GitCommit = "" }
# }
