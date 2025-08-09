output "vpc_id" { value = module.vpc.vpc_id }
output "private_subnets" { value = module.vpc.private_subnet_ids }
output "nat_gateway_count" { value = module.vpc.nat_gateway_count }
