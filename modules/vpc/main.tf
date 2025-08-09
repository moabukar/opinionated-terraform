locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.name}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  count  = var.create_public_subnets ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-igw" })
}

# Subnet CIDRs
locals {
  private_subnet_cidrs = [for i in range(var.az_count) : cidrsubnet(var.cidr, 4, i)]
  public_subnet_cidrs  = [for i in range(var.az_count) : cidrsubnet(var.cidr, 8, 128 + i)]
}

resource "aws_subnet" "private" {
  for_each                = { for idx, az in local.azs : idx => az }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.private_subnet_cidrs[tonumber(each.key)]
  availability_zone       = each.value
  map_public_ip_on_launch = false
  tags                    = merge(var.tags, { Name = "${var.name}-private-${each.value}", Tier = "private" })
}

resource "aws_subnet" "public" {
  for_each                = var.create_public_subnets ? { for idx, az in local.azs : idx => az } : {}
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidrs[tonumber(each.key)]
  availability_zone       = each.value
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.name}-public-${each.value}", Tier = "public" })
}

# NAT
resource "aws_eip" "nat" {
  count = var.nat_gateway_count
  vpc   = true
  tags  = merge(var.tags, { Name = "${var.name}-nat-eip-${count.index}" })
}

resource "aws_nat_gateway" "this" {
  count         = var.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = try(values(aws_subnet.public)[count.index].id, null)
  depends_on    = [aws_internet_gateway.igw]
  tags          = merge(var.tags, { Name = "${var.name}-nat-${count.index}" })
}

# Route tables
resource "aws_route_table" "public" {
  count  = var.create_public_subnets ? 1 : 0
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  tags = merge(var.tags, { Name = "${var.name}-rt-public" })
}

resource "aws_route_table_association" "public" {
  for_each       = var.create_public_subnets ? aws_subnet.public : {}
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id
  dynamic "route" {
    for_each = var.nat_gateway_count > 0 ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = element(aws_nat_gateway.this[*].id, tonumber(each.key) % max(var.nat_gateway_count, 1))
    }
  }
  tags = merge(var.tags, { Name = "${var.name}-rt-private-${each.value.availability_zone}" })
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
