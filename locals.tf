locals {
  eks_ami_query  = var.eks_ami_release_version != null ? "${split(".", var.eks_ami_release_version)[0]}.${split(".", var.eks_ami_release_version)[1]}-v${split("-", var.eks_ami_release_version)[1]}" : null
  eks_amd_ami_id = local.eks_ami_query != null ? data.aws_ami.eks_ami_query[0].id : null

  cloudformation_template_path = "${path.module}/templates/cloudformation-${var.karpenter_version}.yaml"

  use_irsa         = contains(["irsa", "both"], var.auth_mode)
  use_pod_identity = contains(["pod_identity", "both"], var.auth_mode)

  karpenter_node_role_name = "KarpenterNodeRole-${var.cluster_name}"
  interruption_queue_name  = var.cluster_name

  controller_irsa_annotation_set = local.use_irsa ? [{
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller_role[0].arn
  }] : []

  controller_base_helm_sets = var.enable_karpenter_controller ? concat([
    {
      name  = "settings.clusterName"
      value = var.cluster_name
    },
    {
      name  = "settings.interruptionQueue"
      value = local.interruption_queue_name
    },
    {
      name  = "controller.clusterEndpoint"
      value = var.cluster_endpoint
    },
    ], local.controller_irsa_annotation_set, [
    for name, value in var.controller_helm_additional_set : {
      name  = name
      value = tostring(value)
    }
  ]) : []

  node_pool_releases = var.enable_node_pools ? { for np in var.node_pools : np.name => np } : {}

  karpenter_controller_assume_role_policy = !var.enable_karpenter_controller ? null : (
    local.use_irsa && local.use_pod_identity ? data.aws_iam_policy_document.karpenter_controller_combined_trust[0].json : (
      local.use_irsa ? data.aws_iam_policy_document.karpenter_controller_assume_role_policy[0].json :
      data.aws_iam_policy_document.karpenter_controller_pod_identity_trust[0].json
    )
  )
}
