module "vpc" {
  source          = "../../"
  name            = "example"
  cidr            = "10.20.0.0/16"
  public_subnets  = ["10.20.0.0/24", "10.20.1.0/24", "10.20.2.0/24"]
  private_subnets = ["10.20.10.0/24", "10.20.11.0/24", "10.20.12.0/24"]
  nat_gateways    = 1
  tags            = { Environment = "test", Name = "example", GitCommit = "" }
}
