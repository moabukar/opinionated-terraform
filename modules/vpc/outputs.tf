output "vpc_id" { value = aws_vpc.this.id }
output "private_subnet_ids" { value = values(aws_subnet.private)[*].id }
output "public_subnet_ids" { value = try(values(aws_subnet.public)[*].id, []) }
output "nat_gateway_ids" { value = aws_nat_gateway.this[*].id }
output "flow_log_id" { value = try(aws_flow_log.this[0].id, null) }
