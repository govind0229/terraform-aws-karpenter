# Karpenter Node Pool Terraform Module

This Terraform module creates Karpenter node pools and associated resources using Helm.

### Features

- Dynamically create multiple Karpenter node pools based on user-defined configurations.
- Configure AMI IDs, IAM roles, subnet discovery tags, and custom tags for each node pool.
- Utilize Helm to manage the lifecycle of Karpenter resources.

### Usage

```hcl
module "karpenter" {
  source  = "govind0229/karpenter/aws"


  cluster_name                        = "cluster1"
  cluster_endpoint                    = "https://xyz"
  cluster_openid_connect_provider_arn = "xyz"
  cluster_openid_connect_provider_url = "https://xyz"
  

// To automatically update the EKS node AMI image when updating EKS, you can use the `eks_ami_release_version` variable and set `eks_custom_ami_id` = null in node_pools configuration:

  eks_ami_release_version = "1.28.8-20240703" 

// if you need to set custom eks nodes ami to use `eks_custom_ami_id` in node_pools configuration:

  node_pools = [
    {
      name                  = "karpenter-nodepool-1"
      eks_custom_ami_id     = ""                          # This is being manually specified eks nodes ami id
      subnet_discovery_tag  = "cluster1"                  # The cluster name you used to tag the worker subnets.
      tags = {
        environment_name          = "dev"
        instanceName              = "Karpenter-cluster1"
        # "cost-control:purpose"  = "testing"
        owner                     = "user1"
      }
    },
    # {
    #  name                  = "karpenter-nodepool-2"
    #  eks_custom_ami_id     = ""                           # This is being manually specified eks nodes ami id
    #  subnet_discovery_tag  = "cluster1"                   # The cluster name you used to tag the worker subnets.
    #  tags = {
    #    environment_name         = "dev"
    #    instanceName             = "Karpenter-cluster2"
    #    # "cost-control:purpose" = "testing"
    #    owner                    = "user2"
    #  }
    # }
  ]
}
```

#### Subnet Tagging
For `ec2nodeclass`, you need to tag your `subnets` using the following `key:value` pair. The value clould be the `cluster name` for identification:

```hcl
tag_key   = "karpenter.sh/discovery"
tag_value = "Cluster_name"
```

##### Outputs

This module does not have any outputs.

##### Providers

- `aws` - The AWS provider.
- `helm` - The Helm provider.

### Requirements
- Terraform >= 0.14.0
- AWS provider >= 3.0
- Helm provider >= 2.0
