# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [2.0.0] - 2026-11-04

### Added

- Vendored CloudFormation templates under `templates/cloudformation-<version>.yaml`
- `auth_mode` for IRSA, EKS Pod Identity, or both
- Feature flags: `enable_karpenter_controller`, `enable_cloudformation`, `enable_node_pools`
- Extended `node_pools` (limits, taints, labels, requirements, disruption, `ami_family`)
- `controller_helm_additional_set`, `settings.interruptionQueue` on controller Helm release
- Module outputs and `examples/complete`
- CI workflow (fmt, validate, helm template)
- [UPGRADE.md](UPGRADE.md)

### Changed

- Default `karpenter_version` to `1.2.0`
- Helm provider `>= 3.0.0` list-style `set` blocks
- Safer AMI resolution and validation for node pools
- EC2 instance tags use `tags.environment_name` and `tags.instanceName`

### Removed

- Runtime HTTP fetch of CloudFormation from GitHub
- Unused `kubernetes` and `cloudposse/utils` provider requirements
- `lifecycle.ignore_changes` on CloudFormation and IAM policy attachment

### Fixed

- Plan failure when `eks_ami_release_version` was null
- Invalid `instanceName` attribute on node pool objects

## [1.0.3] - 2024-11-15

### Changed

- Update `main.tf` to remove `try` function for `ec2nodeclass.amiId` to handle `null` values and fallback to `local.eks_amd_ami_id`.
- Update `NodeGroup` for Reference `EC2NodeClass`

## [1.0.2] - 2024-11-14

### Changed

- Fixed unknown error with data resource.
- Added condition to manage and allow the option to use a given EKS custom AMI ID for the node pool.

## [1.0.1] - 2024-11-13

### Changed

- Updated `main.tf` to dynamically create `karpenter_nodepool` resources based on user-defined configurations.
- Modified `name` attribute in `helm_release` resource to correctly reference the node pool name.
- Updated node-pools Helm chart to correctly reference the node pool name.

## [1.0.0] - 2024-11-12

### Added

- Initial release of the Karpenter Node Pool Terraform Module.
- Support for creating multiple Karpenter node pools dynamically based on user-defined configurations.
- Configuration options for AMI IDs, IAM roles, subnet discovery tags, and custom tags for each node pool.
- Integration with Helm to manage the lifecycle of Karpenter resources.
- Define a variable to automatically fetch the latest EKS-optimized AMI.
- Remove the `ami_id` from the node pool configuration.
