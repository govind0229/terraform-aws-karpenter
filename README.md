# Karpenter Terraform Module

Terraform module to install [Karpenter](https://karpenter.sh/) on Amazon EKS: CloudFormation IAM/SQS, controller Helm release (IRSA and/or EKS Pod Identity), and optional NodePool / EC2NodeClass Helm releases.

## Features

- Vendored Karpenter CloudFormation (no runtime fetch from GitHub)
- Controller auth: `irsa`, `pod_identity`, or `both`
- Feature flags: controller, CloudFormation, node pools
- Configurable node pools (limits, taints, labels, requirements, disruption)
- EKS-optimized AMI lookup or per-pool custom AMI

## Usage

```hcl
module "karpenter" {
  source = "govind0229/karpenter/aws"

  cluster_name                        = "my-cluster"
  cluster_endpoint                    = "https://..."
  cluster_openid_connect_provider_arn = "arn:aws:iam::123456789012:oidc-provider/..."
  cluster_openid_connect_provider_url = "https://oidc.eks.region.amazonaws.com/id/..."

  auth_mode         = "irsa" # Fargate: irsa. MNG nodes: pod_identity or both
  karpenter_version = "1.2.0"

  eks_ami_release_version = "1.29.0-20241001"

  node_pools = [
    {
      name                 = "default"
      subnet_discovery_tag = "my-cluster"
      tags = {
        environment_name = "dev"
        instanceName     = "karpenter-my-cluster"
        owner            = "platform"
      }
    },
  ]
}
```

See [examples/complete](examples/complete) and [UPGRADE.md](UPGRADE.md).

### Subnet tagging

Tag subnets for discovery:

```text
karpenter.sh/discovery = <cluster_name_or_tag_value>
```

Match `subnet_discovery_tag` on each node pool.

### Private clusters

Ensure VPC endpoints for STS, EC2, and SSM (and other services Karpenter uses). See [Amazon EKS Karpenter best practices](https://docs.aws.amazon.com/eks/latest/best-practices/karpenter.html).

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 5.30.0 |
| helm | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| cluster_name | EKS cluster name | `string` | required |
| cluster_endpoint | EKS API endpoint | `string` | required |
| cluster_openid_connect_provider_arn | OIDC provider ARN (required unless `auth_mode = pod_identity`) | `string` | `null` |
| cluster_openid_connect_provider_url | OIDC provider URL (required unless `auth_mode = pod_identity`) | `string` | `null` |
| auth_mode | `irsa`, `pod_identity`, or `both` | `string` | `"irsa"` |
| service_account_name | Controller service account | `string` | `"karpenter"` |
| enable_karpenter_controller | Install controller Helm release | `bool` | `true` |
| enable_cloudformation | Create Karpenter CloudFormation stack | `bool` | `true` |
| enable_node_pools | Install NodePool / EC2NodeClass charts | `bool` | `true` |
| karpenter_version | Karpenter chart version (needs matching `templates/cloudformation-*.yaml`) | `string` | `"1.2.0"` |
| namespace | Controller namespace | `string` | `"kube-system"` |
| controller_helm_additional_set | Extra Helm sets for controller | `map(string)` | `{}` |
| node_pools | Node pool definitions | `list(object)` | `[]` |
| eks_ami_release_version | EKS AMI release when pools omit `eks_custom_ami_id` | `string` | `null` |

## Outputs

| Name | Description |
|------|-------------|
| karpenter_controller_role_arn | Controller IAM role ARN |
| karpenter_node_role_name | Node IAM role name |
| interruption_queue_name | SQS interruption queue name |
| karpenter_cloudformation_stack_id | CloudFormation stack ID |
| karpenter_pod_identity_association_id | Pod Identity association ID |

## Node pools only

```hcl
enable_karpenter_controller = false
enable_cloudformation       = false # if IAM/SQS already exist
enable_node_pools           = true
```

CloudFormation must already provide `KarpenterNodeRole-<cluster>` and related resources.

## Auth mode matrix

| Controller runs on | Suggested `auth_mode` |
|--------------------|------------------------|
| EKS Fargate | `irsa` |
| Managed / Karpenter nodes | `pod_identity` or `both` |

## License

MIT
