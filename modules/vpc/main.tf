data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  required_tags = {
    Owner      = "platform@coderco.dev"
    ManagedBy  = "Terraform"
    Repo       = "coderco/terraform-aws-mono"
    CostCenter = "ENG-PLATFORM"
  }
  all_tags = merge(local.required_tags, var.tags)
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.all_tags, { Name = "${var.name}-vpc", Environment = local.all_tags.Environment, GitCommit = "" })
}

resource "aws_internet_gateway" "this" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = merge(local.all_tags, { Name = "${var.name}-igw" })
}

resource "aws_subnet" "public" {
  for_each                = { for idx, cidr in var.public_subnets : idx => cidr }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}${substr("abc", tonumber(each.key), 1)}"
  tags                    = merge(local.all_tags, { Name = "${var.name}-public-${each.key}", Tier = "public" })
}

resource "aws_subnet" "private" {
  for_each          = { for idx, cidr in var.private_subnets : idx => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = "${data.aws_region.current.name}${substr("abc", tonumber(each.key), 1)}"
  tags              = merge(local.all_tags, { Name = "${var.name}-private-${each.key}", Tier = "private" })
}

resource "aws_eip" "nat" {
  count = var.nat_gateways
  vpc   = true
  tags  = merge(local.all_tags, { Name = "${var.name}-nat-eip-${count.index}" })
}

resource "aws_nat_gateway" "this" {
  count         = var.nat_gateways
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(values(aws_subnet.public)[*].id, count.index)
  tags          = merge(local.all_tags, { Name = "${var.name}-nat-${count.index}" })
  depends_on    = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = merge(local.all_tags, { Name = "${var.name}-rtb-public" })
}

resource "aws_route" "public_inet" {
  count                  = length(var.public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id
  tags     = merge(local.all_tags, { Name = "${var.name}-rtb-private-${each.key}" })
}

resource "aws_route" "private_nat" {
  for_each               = aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateways > 0 && length(aws_nat_gateway.this) > 0 ? element(aws_nat_gateway.this[*].id, tonumber(each.key) % var.nat_gateways) : null
  lifecycle { ignore_changes = all }
}

# VPC endpoints for SSM (private management)
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = values(aws_subnet.private)[*].id
  security_group_ids = [aws_security_group.endpoints.id]
  tags               = merge(local.all_tags, { Name = "${var.name}-vpce-ssm" })
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = values(aws_subnet.private)[*].id
  security_group_ids = [aws_security_group.endpoints.id]
  tags               = merge(local.all_tags, { Name = "${var.name}-vpce-ssmmessages" })
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = values(aws_subnet.private)[*].id
  security_group_ids = [aws_security_group.endpoints.id]
  tags               = merge(local.all_tags, { Name = "${var.name}-vpce-ec2messages" })
}

resource "aws_security_group" "endpoints" {
  name        = "${var.name}-endpoints-sg"
  description = "Interface VPC endpoints"
  vpc_id      = aws_vpc.this.id
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [var.cidr]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.all_tags, { Name = "${var.name}-endpoints-sg" })
}

# Flow logs to CloudWatch with KMS
resource "aws_kms_key" "flowlogs" {
  count               = var.enable_flow_logs ? 1 : 0
  description         = "KMS for VPC Flow Logs"
  enable_key_rotation = true
  tags                = merge(local.all_tags, { Name = "${var.name}-kms-flowlogs" })
}

resource "aws_cloudwatch_log_group" "flowlogs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/vpc/${var.name}/flowlogs"
  retention_in_days = 14
  kms_key_id        = var.enable_flow_logs ? aws_kms_key.flowlogs[0].arn : null
  tags              = local.all_tags
}

resource "aws_flow_log" "this" {
  count                       = var.enable_flow_logs ? 1 : 0
  log_destination_type        = "cloud-watch-logs"
  traffic_type                = "ALL"
  deliver_logs_permission_arn = null
  log_group_name              = aws_cloudwatch_log_group.flowlogs[0].name
  iam_role_arn                = null
  vpc_id                      = aws_vpc.this.id
  tags                        = local.all_tags
}
