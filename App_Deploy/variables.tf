# Common tags to be assigned to all resources
locals {
  common_tags = {
    Name      = "App_Deploy_Project"
    Owner     = "API_MGMT_DEV"
    AppTeam   = "Cloud Team"
    CreatedBy = "TerraformUser"
  }
}

# AWS Region = London
variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

# Name associated to VPC used to deploy the application
variable "vpc_name" {
  type    = string
  default = "web_app_vpc"
}

# Define the type of EC2 intances that will be used throughout the code. Currently using free tier only
variable "ec2_type" {
  type    = string
  default = "t2.micro"
}

# CIDR Block for the VPC Subnet
variable "vpc_cidr" {
  type    = string
  default = "150.0.0.0/16"
}

# Define 2 private subnets
variable "private_vpc_subnets" {
  default = {
    "private_subnet_1" = 1
    "private_subnet_2" = 2
  }
}

# Define 2 public subnets
variable "public_vpc_subnets" {
  default = {
    "public_subnet_1" = 1
    "public_subnet_2" = 2
  }
}