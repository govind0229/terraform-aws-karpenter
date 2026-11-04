output "karpenter_controller_role_arn" {
  description = "IAM role ARN for the Karpenter controller"
  value       = try(aws_iam_role.karpenter_controller_role[0].arn, null)
}

output "karpenter_node_role_name" {
  description = "IAM role name for Karpenter-provisioned nodes"
  value       = local.karpenter_node_role_name
}

output "interruption_queue_name" {
  description = "SQS queue name for EC2 interruption handling"
  value       = local.interruption_queue_name
}

output "karpenter_cloudformation_stack_id" {
  description = "CloudFormation stack ID when enable_cloudformation is true"
  value       = try(aws_cloudformation_stack.karpenter[0].id, null)
}

output "karpenter_pod_identity_association_id" {
  description = "EKS Pod Identity association ID when auth_mode includes pod_identity"
  value       = try(aws_eks_pod_identity_association.karpenter[0].association_id, null)
}
