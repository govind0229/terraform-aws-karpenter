// Karpenter Helm Chart Installation
resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version
  namespace  = var.namespace

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "controller.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller_role.arn
  }


  depends_on = [
    aws_cloudformation_stack.karpenter,
  ]
}

// Karpenter node pool and node role creation
resource "helm_release" "karpenter_nodepool" {
  for_each = { for np in var.node_pools : np.name => np }

  depends_on = [helm_release.karpenter]

  name  = each.value.name
  chart = "${path.module}/node-pools"

  set {
    name  = "name"
    value = each.value.name
  }
  
  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "ec2nodeclass.amiId"
    value = try(each.value.ami_id, data.aws_ami.eks_ami.id)
  }

  set {
    name  = "ec2nodeclass.role"
    value = "KarpenterNodeRole-${var.cluster_name}"
  }

  set {
    name  = "ec2nodeclass.subnetDiscoveryTag"
    value = each.value.subnet_discovery_tag
  }

  set {
    name  = "ec2nodeclass.tags.environment_name"
    value = each.value.tags["environment_name"]
  }

  set {
    name  = "ec2nodeclass.tags.InstanceName"
    value = try(each.value.instanceName, "${var.cluster_name}-${each.value.name}")
  }

  set {
    name  = "ec2nodeclass.tags.costControlPurpose"
    value = try(each.value.tags["cost-control:purpose"], "karpenter")
  }

  set {
    name  = "ec2nodeclass.tags.expiry"
    value = try(each.value.tags["expiry"], "never")
  }

  set {
    name  = "ec2nodeclass.tags.owner"
    value = each.value.tags["owner"]
  }
}

// Karpenter node role creation and policy attachment to the role
resource "aws_cloudformation_stack" "karpenter" {
  name          = "Karpenter-${var.cluster_name}"
  template_body = data.http.karpenter_cloudformation.response_body

  capabilities = ["CAPABILITY_NAMED_IAM"]

  parameters = {
    ClusterName = var.cluster_name
  }

  lifecycle {
    ignore_changes = [template_body]
  }
}
