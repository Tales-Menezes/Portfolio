
# ############################################################################################################# #
# In this file we declare the remote backend that will manage the state file configuration for the App.         #
# It defines the required providers and the version contrains used for this application.                        #
# It defines the version of Terraform that will be used.                                                        #
# ############################################################################################################# #

terraform {
  cloud {
    organization = "Tales-Organization"

    workspaces {
      name = "App-Deployment"
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