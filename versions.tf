// Required Terraform version
terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.16.1"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.5"
    }
  }
}
