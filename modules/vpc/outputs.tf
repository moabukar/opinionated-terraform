output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = values(aws_subnet.public)[*].id }
output "private_subnet_ids" { value = values(aws_subnet.private)[*].id }
output "nat_gateway_count" { value = length(aws_nat_gateway.this) }
output "flow_logs_enabled" { value = length(aws_flow_log.this) > 0 }
