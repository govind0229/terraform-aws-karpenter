# Upgrade guide

## v1.x → v2.0.0

### CloudFormation template is vendored

The module no longer downloads CloudFormation from GitHub at plan time. Templates live under `templates/cloudformation-<karpenter_version>.yaml`. When upgrading Karpenter, set `karpenter_version` to a value that has a matching file in this module (or add the template from [Karpenter getting-started CloudFormation](https://github.com/aws/karpenter-provider-aws)).

Removing `lifecycle.ignore_changes` on the stack means Terraform may update the stack when the vendored template changes. Review the diff before apply.

### Provider requirements

- Terraform `>= 1.3`
- `hashicorp/helm` `>= 3.0.0` (Helm `set` is a list attribute)
- Removed unused `kubernetes` and `cloudposse/utils` provider requirements

### New variables

- `auth_mode`: `irsa` (default), `pod_identity`, or `both`
- `enable_karpenter_controller`, `enable_cloudformation`, `enable_node_pools`
- `service_account_name`, `controller_helm_additional_set`
- Extended `node_pools` optional fields (limits, taints, labels, requirements, disruption)

### AMI validation

Each node pool must set `eks_custom_ami_id` or set module `eks_ami_release_version`.

### Auth modes

| Workload | Recommended `auth_mode` |
|----------|-------------------------|
| Karpenter on Fargate | `irsa` |
| Karpenter on MNG / Karpenter nodes | `pod_identity` or `both` |

### Node pool tags

Use `tags.instanceName` (not a top-level `instanceName` field). `environment_name` in EC2 tags now comes from `tags.environment_name`.
