resource "aws_cloudformation_stack" "karpenter" {
  count = var.enable_cloudformation ? 1 : 0

  name          = "Karpenter-${var.cluster_name}"
  template_body = file(local.cloudformation_template_path)

  capabilities = ["CAPABILITY_NAMED_IAM"]

  parameters = {
    ClusterName = var.cluster_name
  }

  lifecycle {
    precondition {
      condition     = fileexists(local.cloudformation_template_path)
      error_message = "No vendored CloudFormation template for karpenter_version ${var.karpenter_version}. Add templates/cloudformation-${var.karpenter_version}.yaml or change karpenter_version."
    }
  }
}

resource "helm_release" "karpenter" {
  count = var.enable_karpenter_controller ? 1 : 0

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version
  namespace  = var.namespace

  set = local.controller_base_helm_sets

  depends_on = [
    aws_cloudformation_stack.karpenter,
  ]
}

resource "helm_release" "karpenter_nodepool" {
  for_each = local.node_pool_releases

  depends_on = [
    helm_release.karpenter,
    aws_cloudformation_stack.karpenter,
  ]

  name      = each.value.name
  chart     = "${path.module}/node-pools"
  namespace = var.namespace

  values = [yamlencode({
    name        = each.value.name
    clusterName = var.cluster_name
    ec2nodeclass = {
      amiFamily          = each.value.ami_family
      role               = local.karpenter_node_role_name
      subnetDiscoveryTag = each.value.subnet_discovery_tag
      amiId              = each.value.eks_custom_ami_id != "" ? each.value.eks_custom_ami_id : local.eks_amd_ami_id
      tags = {
        environment_name   = each.value.tags["environment_name"]
        InstanceName       = try(each.value.tags["instanceName"], "${var.cluster_name}-${each.value.name}")
        costControlPurpose = try(each.value.tags["cost-control:purpose"], "karpenter")
        expiry             = try(each.value.tags["expiry"], "never")
        owner              = each.value.tags["owner"]
      }
    }
    nodepool = {
      weight = each.value.weight
      limits = each.value.limits
      labels = each.value.labels
      taints = each.value.taints
      requirements = {
        arch               = try(each.value.requirements.arch, ["amd64"])
        os                 = try(each.value.requirements.os, ["linux"])
        capacityType       = try(each.value.requirements.capacity_type, ["on-demand"])
        instanceCategory   = try(each.value.requirements.instance_category, ["c", "m", "r"])
        instanceGeneration = try(each.value.requirements.instance_generation, ["4"])
        instanceType       = try(each.value.requirements.instance_type_not_in, ["m6g.16xlarge", "m6gd.16xlarge", "r6g.16xlarge", "r6gd.16xlarge", "c6g.16xlarge"])
      }
      nodeClassRef = {
        group = "karpenter.k8s.aws"
        kind  = "EC2NodeClass"
        name  = each.value.name
      }
      expireAfter = each.value.expire_after
      disruption = {
        consolidationPolicy = try(each.value.disruption.consolidation_policy, "WhenEmptyOrUnderutilized")
        consolidateAfter    = try(each.value.disruption.consolidate_after, "15s")
        budgets = {
          nodes = try(each.value.disruption.budget_nodes, "10%")
        }
      }
    }
  })]
}
