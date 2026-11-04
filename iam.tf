data "aws_iam_policy_document" "karpenter_controller_pod_identity_trust" {
  count = var.enable_karpenter_controller && local.use_pod_identity ? 1 : 0

  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "karpenter_controller_combined_trust" {
  count = var.enable_karpenter_controller && local.use_irsa && local.use_pod_identity ? 1 : 0

  source_policy_documents = [
    data.aws_iam_policy_document.karpenter_controller_assume_role_policy[0].json,
    data.aws_iam_policy_document.karpenter_controller_pod_identity_trust[0].json,
  ]
}

resource "aws_iam_role" "karpenter_controller_role" {
  count = var.enable_karpenter_controller ? 1 : 0

  name               = "${var.cluster_name}-karpenter"
  assume_role_policy = local.karpenter_controller_assume_role_policy

  depends_on = [aws_cloudformation_stack.karpenter]
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_policy_attachment" {
  count = var.enable_karpenter_controller ? 1 : 0

  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/KarpenterControllerPolicy-${var.cluster_name}"
  role       = aws_iam_role.karpenter_controller_role[0].name

  depends_on = [aws_cloudformation_stack.karpenter]
}

resource "aws_eks_pod_identity_association" "karpenter" {
  count = var.enable_karpenter_controller && local.use_pod_identity ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account_name
  role_arn        = aws_iam_role.karpenter_controller_role[0].arn
}
