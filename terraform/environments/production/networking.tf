################################################################################
# VPC
################################################################################

resource "aws_vpc" "oracle" {

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "oracle" {

  vpc_id = aws_vpc.oracle.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}

################################################################################
# Public Subnet
################################################################################

resource "aws_subnet" "public" {

  vpc_id = aws_vpc.oracle.id

  cidr_block = var.public_subnet_cidr

  availability_zone = var.availability_zone

  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-public-subnet"
    }
  )

}

################################################################################
# Private Subnet
################################################################################

resource "aws_subnet" "private" {

  vpc_id = aws_vpc.oracle.id

  cidr_block = var.private_subnet_cidr

  availability_zone = var.availability_zone

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-private-subnet"
    }
  )

}


################################################################################
# Secondary Private Subnet - DR Standby
################################################################################

resource "aws_subnet" "private_secondary" {

  vpc_id = aws_vpc.oracle.id

  cidr_block = var.private_subnet_cidr_secondary

  availability_zone = var.availability_zone_secondary

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-private-subnet-secondary"
    }
  )

}

################################################################################
# Elastic IP
################################################################################

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-nat-eip"
    }
  )

}

################################################################################
# NAT Gateway
################################################################################

resource "aws_nat_gateway" "oracle" {

  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public.id

  depends_on = [
    aws_internet_gateway.oracle
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-nat"
    }
  )

}

################################################################################
# Public Route Table
################################################################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.oracle.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-public-rt"
    }
  )

}

################################################################################
# Public Internet Route
################################################################################

resource "aws_route" "public_internet" {

  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.oracle.id

}

################################################################################
# Private Route Table
################################################################################

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.oracle.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-private-rt"
    }
  )

}

################################################################################
# Private NAT Route
################################################################################

resource "aws_route" "private_nat" {

  route_table_id = aws_route_table.private.id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.oracle.id

}

################################################################################
# Public Association
################################################################################

resource "aws_route_table_association" "public" {

  subnet_id = aws_subnet.public.id

  route_table_id = aws_route_table.public.id

}

################################################################################
# Private Association
################################################################################

resource "aws_route_table_association" "private" {

  subnet_id = aws_subnet.private.id

  route_table_id = aws_route_table.private.id

}


################################################################################
# Secondary Private Route Table Association
################################################################################

resource "aws_route_table_association" "private_secondary" {

  subnet_id = aws_subnet.private_secondary.id

  route_table_id = aws_route_table.private.id

}