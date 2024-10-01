
# ############################################################################################################# #
# This file deploys a VPC with 2 private and 2 public subnets                                                   #
# Creates a route table and associate to each subnet                                                            #
# Creates an internet gateway and associate it with the public subnet to give it access to internet connection  #
# Allocate a NAT gateway and elastic IP (EIP) in the public subnet 1                                            #
# ############################################################################################################# #

# Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {
  name = "us-east-1"
}

# Define the VPC 
resource "aws_vpc" "vpc" {

  cidr_block           = var.vpc_cidr
  tags                 = local.common_tags
  enable_dns_hostnames = true

}

# Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_vpc_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

  tags = {
    Name      = each.key
    CreatedBy = "TerraformUser"
  }
}

# Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_vpc_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value]
  map_public_ip_on_launch = true # Allocate a public IP for the public subnet

  tags = {
    Name      = each.key
    CreatedBy = "TerraformUser"
  }
}

# Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = local.common_tags
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = local.common_tags
}

# Create route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.common_tags
}

# Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags       = local.common_tags
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags          = local.common_tags
}