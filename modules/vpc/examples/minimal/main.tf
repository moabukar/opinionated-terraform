provider "aws" { region = "eu-west-2" }

module "vpc" {
  source            = "../../"
  name              = "coderco-test"
  cidr              = "10.20.0.0/16"
  nat_gateway_count = 1
}
