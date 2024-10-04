terraform {
  cloud {
    organization = "Tales-Organization"

    workspaces {
      name = "S3-Static-Website"
    }
  }

  required_version = "~> 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Define AWS region where the website will be hosted
provider "aws" {
  region = var.region
}
