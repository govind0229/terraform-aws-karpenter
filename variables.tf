// EKS cluster required variables
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  type        = string
}

variable "cluster_openid_connect_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "cluster_openid_connect_provider_url" {
  description = "The URL of the OIDC provider for the EKS cluster"
  type        = string
}

// Karpenter required variables
variable "karpenter_version" {
  description = "The version of Karpenter to install"
  type        = string
  default     = "1.0.1"
}

variable "namespace" {
  description = "The namespace to install Karpenter into"
  type        = string
  default     = "kube-system"
}

// Karpenter node pool required variables
variable "node_pools" {
  description = "List of node pool configurations"
  type = list(object({
    name                 = string
    subnet_discovery_tag = string
    eks_custom_ami_id    = string
    tags                 = map(string)
  }))
  default = []
}

variable "eks_ami_release_version" {
  description = "The version of the EKS AMI to use e.g. `1.28.13-20240928`"
  type        = string
  default     = null 
}

