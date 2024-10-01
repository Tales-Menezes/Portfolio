# Common tags to be assigned to all resources
locals {
  common_tags = {
    Name      = "Two_Tier_Project"
    Owner     = "API_MGMT_DEV"
    AppTeam   = "Cloud Team"
    CreatedBy = "TerraformUser"
  }
}

variable "aws_region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS Region: London"
}

variable "vpc_name" {
  type        = string
  default     = "two-tier-vpc"
  description = "Name associated to VPC used to deploy the application"
}

variable "ec2_type" {
  type        = string
  default     = "t2.micro"
  description = "Define the type of EC2 intances that will be used throughout the code. Currently using free tier only"
}

variable "vpc_cidr" {
  type        = string
  default     = "150.0.0.0/16"
  description = "CIDR Block for the VPC Subnet"
}

variable "private_vpc_subnets" {
  default = {
    "private_subnet_1" = 1
    "private_subnet_2" = 2
  }
  description = "Define 2 private subnets"
}

variable "public_vpc_subnets" {
  default = {
    "public_subnet_1" = 1
    "public_subnet_2" = 2
  }
  description = "Define 2 public subnets"
}

variable "lb_name" {
  default     = "two-tier-lb"
  description = "Define the name of the Elastic Load Balancer"
}

variable "tg_name" {
  default     = "two-tier-tg"
  description = "Define the name of the target group for the Load Balancer"
}

variable "db_subnet" {
  default = "db-subnet-group"
}

variable "db_username" {
  description = "Database username"
}

variable "db_password" {
  description = "database password"
}