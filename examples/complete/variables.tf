variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_certificate_authority_data" {
  type = string
}

variable "cluster_openid_connect_provider_arn" {
  type = string
}

variable "cluster_openid_connect_provider_url" {
  type = string
}

variable "auth_mode" {
  type    = string
  default = "irsa"
}

variable "karpenter_version" {
  type    = string
  default = "1.2.0"
}

variable "eks_ami_release_version" {
  type = string
}

variable "node_pools" {
  type = any
}
