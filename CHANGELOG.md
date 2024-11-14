# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

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
