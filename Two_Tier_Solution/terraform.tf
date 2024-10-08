
# ############################################################################################################# #
# This file defines:                                                                                            #
# The remote backend that will manage the state file configuration for the App.                                 #
# The required providers and the version constrains used for this application.                                  #
# The version of Terraform that will be used.                                                                   #
# The AWS region where the app will be hosted.                                                                  #
# ############################################################################################################# #

terraform {
  cloud {
    organization = "Tales-Organization"

    workspaces {
      name = "Two-Tier-Deployment"
    }
  }

  required_version = "~> 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.68.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
}

# Define AWS region where the app will be hosted
provider "aws" {
  region = var.aws_region
}