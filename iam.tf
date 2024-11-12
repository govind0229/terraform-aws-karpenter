// IAM Role for Karpenter Controller to assume and attach the policy to the role created
resource "aws_iam_role" "karpenter_controller_role" {
  name               = "${var.cluster_name}-karpenter"
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role_policy.json

  depends_on = [aws_cloudformation_stack.karpenter]
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_policy_attachment" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/KarpenterControllerPolicy-${var.cluster_name}"
  role       = aws_iam_role.karpenter_controller_role.name

  depends_on = [aws_cloudformation_stack.karpenter]

  lifecycle {
    ignore_changes = [policy_arn]
  }
}


