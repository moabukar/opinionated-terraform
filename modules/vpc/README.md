# VPC

- 3 AZ private subnets
- Optional public subnets
- NAT gateways (configurable count)
- Flow Logs to CloudWatch with KMS
- SSM endpoints (ssm, ssmmessages, ec2messages)

## Example
```hcl
module "vpc" {
  source                 = "../../modules/vpc"
  name                   = "coderco-dev"
  cidr                   = "10.10.0.0/16"
  nat_gateway_count      = 1
  create_public_subnets  = true
  tags = {
    Name        = "coderco-dev"
    Environment = "dev"
    Owner       = "platform@coderco.dev"
    ManagedBy   = "Terraform"
    Repo        = "coderco/infra"
    GitCommit   = "local"
    CostCenter  = "ENG-PLATFORM"
  }
}
