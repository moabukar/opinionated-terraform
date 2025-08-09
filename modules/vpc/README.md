# VPC

Creates a VPC with optional public subnets, private subnets, NAT gateways, SSM interface endpoints, and flow logs -> CloudWatch (KMS-encrypted).

## Example
```hcl
module "vpc" {
  source          = "../../"
  name            = "demo"
  cidr            = "10.0.0.0/16"
  public_subnets  = ["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24"]
  private_subnets = ["10.0.10.0/24","10.0.11.0/24","10.0.12.0/24"]
  nat_gateways    = 1
  tags = { Environment = "dev", Name = "demo" }
}
