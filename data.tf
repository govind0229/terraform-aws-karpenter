data "aws_caller_identity" "current" {}

data "aws_ami" "eks_ami_query" {
  count = local.eks_ami_query != null ? 1 : 0

  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.eks_ami_query}*"]
  }

  filter {
    name   = "owner-id"
    values = ["602401143452"]
  }

  owners = ["602401143452"]
}

data "aws_iam_policy_document" "karpenter_controller_assume_role_policy" {
  count = local.use_irsa && var.enable_karpenter_controller ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_openid_connect_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_openid_connect_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      type        = "Federated"
      identifiers = [var.cluster_openid_connect_provider_arn]
    }
  }
}
