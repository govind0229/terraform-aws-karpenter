terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes = {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  }
}

module "karpenter" {
  source = "../.."

  cluster_name                        = var.cluster_name
  cluster_endpoint                    = var.cluster_endpoint
  cluster_openid_connect_provider_arn = var.cluster_openid_connect_provider_arn
  cluster_openid_connect_provider_url = var.cluster_openid_connect_provider_url

  auth_mode         = var.auth_mode
  karpenter_version = var.karpenter_version

  eks_ami_release_version = var.eks_ami_release_version

  node_pools = var.node_pools
}
