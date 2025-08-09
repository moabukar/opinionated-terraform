module "vpc" {
  source          = "../../modules/vpc"
  name            = "local"
  cidr            = var.vpc_cidr
  public_subnets  = ["10.100.0.0/24", "10.100.1.0/24", "10.100.2.0/24"]
  private_subnets = ["10.100.10.0/24", "10.100.11.0/24", "10.100.12.0/24"]
  nat_gateways    = 1
  tags            = { Environment = "local", Name = "local", GitCommit = "" }
}

# module "ecr" {
#   source = "../../modules/ecr"
#   name   = "local/demo"
#   tags   = { Environment = "local", Name = "local-ecr", GitCommit = "" }
# }
