variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  type        = string
}

variable "cluster_openid_connect_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster (required when auth_mode includes irsa)"
  type        = string
  default     = null

  validation {
    condition     = var.auth_mode == "pod_identity" || var.cluster_openid_connect_provider_arn != null
    error_message = "cluster_openid_connect_provider_arn is required when auth_mode is irsa or both."
  }
}

variable "cluster_openid_connect_provider_url" {
  description = "The URL of the OIDC provider for the EKS cluster (required when auth_mode includes irsa)"
  type        = string
  default     = null

  validation {
    condition     = var.auth_mode == "pod_identity" || var.cluster_openid_connect_provider_url != null
    error_message = "cluster_openid_connect_provider_url is required when auth_mode is irsa or both."
  }
}

variable "auth_mode" {
  description = "Controller AWS credentials: irsa, pod_identity, or both (Fargate requires irsa)"
  type        = string
  default     = "irsa"

  validation {
    condition     = contains(["irsa", "pod_identity", "both"], var.auth_mode)
    error_message = "auth_mode must be irsa, pod_identity, or both."
  }
}

variable "service_account_name" {
  description = "Karpenter controller service account name"
  type        = string
  default     = "karpenter"
}

variable "enable_karpenter_controller" {
  description = "Install Karpenter controller Helm release and controller IAM"
  type        = bool
  default     = true
}

variable "enable_cloudformation" {
  description = "Create Karpenter CloudFormation stack (node role, controller policy, interruption queue)"
  type        = bool
  default     = true
}

variable "enable_node_pools" {
  description = "Install NodePool and EC2NodeClass Helm releases"
  type        = bool
  default     = true
}

variable "karpenter_version" {
  description = "Karpenter Helm chart version (must have a matching templates/cloudformation-<version>.yaml)"
  type        = string
  default     = "1.2.0"
}

variable "namespace" {
  description = "Namespace to install Karpenter into"
  type        = string
  default     = "kube-system"
}

variable "controller_helm_additional_set" {
  description = "Extra Helm set pairs for the Karpenter controller chart"
  type        = map(string)
  default     = {}
}

variable "node_pools" {
  description = "Node pool configurations"
  type = list(object({
    name                 = string
    subnet_discovery_tag = string
    eks_custom_ami_id    = optional(string, "")
    tags                 = map(string)
    ami_family           = optional(string, "AL2")
    weight               = optional(number, 1)
    expire_after         = optional(string, "720h")
    limits = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }), null)
    labels = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = optional(string, "")
      effect = string
    })), [])
    requirements = optional(object({
      arch                 = optional(list(string), ["amd64"])
      os                   = optional(list(string), ["linux"])
      capacity_type        = optional(list(string), ["on-demand"])
      instance_category    = optional(list(string), ["c", "m", "r"])
      instance_generation  = optional(list(string), ["4"])
      instance_type_not_in = optional(list(string), ["m6g.16xlarge", "m6gd.16xlarge", "r6g.16xlarge", "r6gd.16xlarge", "c6g.16xlarge"])
    }), {})
    disruption = optional(object({
      consolidation_policy = optional(string, "WhenEmptyOrUnderutilized")
      consolidate_after    = optional(string, "15s")
      budget_nodes         = optional(string, "10%")
    }), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for np in var.node_pools :
      np.eks_custom_ami_id != "" || var.eks_ami_release_version != null
    ])
    error_message = "Each node pool needs eks_custom_ami_id or module-level eks_ami_release_version."
  }
}

variable "eks_ami_release_version" {
  description = "EKS optimized AMI release e.g. 1.28.13-20240928 (used when pool eks_custom_ami_id is empty)"
  type        = string
  default     = null
}
