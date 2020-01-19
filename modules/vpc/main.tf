resource "aws_vpc" "this" {
  cidr_block = var.web_vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support = true
}

# subnets
resource "aws_subnet" "public" {
  count = length(var.web_vpc_public_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = element(var.web_vpc_public_subnets, count.index)
  availability_zone = element(var.azs, count.index)
}

resource "aws_subnet" "private_web" {
  count = length(var.web_vpc_private_web_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = element(var.web_vpc_private_web_subnets, count.index)
  availability_zone = element(var.azs, count.index)
}

resource "aws_subnet" "private_app" {
  count = length(var.web_vpc_privte_app_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = element(var.web_vpc_privte_app_subnets, count.index)
  availability_zone = element(var.azs, count.index)
}

# internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

}

# nat gateways
resource "aws_eip" "nat" {
  count = length(var.azs)

  vpc = true
}

resource "aws_nat_gateway" "this" {
  count = length(var.azs)

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id = element(aws_subnet.public.*.id, count.index)
}

# route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table" "private" {
  count = length(var.azs)

  vpc_id = aws_vpc.this.id
}

resource "aws_route_table_association" "public" {
  count = length(var.web_vpc_public_subnets)

  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_web" {
  count = length(var.web_vpc_private_web_subnets)

  subnet_id = element(aws_subnet.private_web.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "private_app" {
  count = length(var.web_vpc_privte_app_subnets)

  subnet_id = element(aws_subnet.private_app.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

# db vpc
resource "aws_vpc" "db_vpc" {
  cidr_block = var.db_vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_subnet" "private_db" {
  count = length(var.db_vpc_private_subnets)

  vpc_id = aws_vpc.db_vpc.id
  cidr_block = element(var.db_vpc_private_subnets, count.index)
  availability_zone = element(var.azs, count.index)
}

data "aws_caller_identity" "peer" {}

# vpc peering
resource "aws_vpc_peering_connection" "this" {
  vpc_id = aws_vpc.this.id
  peer_vpc_id = aws_vpc.db_vpc.id
  peer_owner_id = data.aws_caller_identity.peer.account_id
  auto_accept = "true"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route_table" "db_private" {
  vpc_id = aws_vpc.db_vpc.id
}

resource "aws_route_table_association" "private_db" {
  count = length(var.db_vpc_private_subnets)

  subnet_id = element(aws_subnet.private_db.*.id, count.index)
  route_table_id = aws_route_table.db_private.id
}

resource "aws_route" "requestor" {
  count = length(var.web_vpc_privte_app_subnets) * length(var.db_vpc_private_subnets)
  route_table_id = element(aws_route_table.private.*.id, ceil(count.index / length(var.db_vpc_private_subnets)))
  destination_cidr_block = element(var.db_vpc_private_subnets, count.index % length(var.db_vpc_private_subnets))
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  depends_on = [
    aws_route_table.private,
    aws_vpc_peering_connection.this]
}

resource "aws_route" "requestor_nat" {
  count = length(var.azs)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.this.*.id, count.index)
  depends_on = [
    aws_route_table.private]
}

resource "aws_route" "acceptor" {
  count = length(var.db_vpc_private_subnets)
  route_table_id = aws_route_table.db_private.id
  destination_cidr_block = element(var.web_vpc_privte_app_subnets, count.index)
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  depends_on = [
    aws_route_table.db_private,
    aws_vpc_peering_connection.this]
}
