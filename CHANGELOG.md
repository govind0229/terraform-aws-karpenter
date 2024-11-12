# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-11-12

### Added

- Initial release of the Karpenter Node Pool Terraform Module.
- Support for creating multiple Karpenter node pools dynamically based on user-defined configurations.
- Configuration options for AMI IDs, IAM roles, subnet discovery tags, and custom tags for each node pool.
- Integration with Helm to manage the lifecycle of Karpenter resources.
- Define a variable to automatically fetch the latest EKS-optimized AMI.
- Remove the `ami_id` from the node pool configuration.
