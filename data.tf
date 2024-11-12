// Get the current AWS account ID
data "aws_caller_identity" "current" {}

// default cloudformation template from karpenter
data "http" "karpenter_cloudformation" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/website/content/en/preview/getting-started/getting-started-with-karpenter/cloudformation.yaml"
}

// EKS AMI for Karpenter node pool creation
data "aws_ami" "eks_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_ami_release_version}*"]
  }

  filter {
    name   = "owner-id"
    values = ["602401143452"]
  }

  owners = ["602401143452"]
}

// IAM Role for Karpenter Controller to assume and attach the policy to the role created
data "aws_iam_policy_document" "karpenter_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_openid_connect_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:karpenter"]
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
