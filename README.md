# Karpenter Node Pool Terraform Module

This Terraform module creates Karpenter node pools and associated resources using Helm.

### Features

- Dynamically create multiple Karpenter node pools based on user-defined configurations.
- Configure AMI IDs, IAM roles, subnet discovery tags, and custom tags for each node pool.
- Utilize Helm to manage the lifecycle of Karpenter resources.


### Usage

```hcl
module "karpenter_node_pools" {
  source = "karpenter"

  cluster_name                        = "your-cluster-name"
  cluster_endpoint                    = "https://xyz"
  cluster_openid_connect_provider_arn = "xyz"
  cluster_openid_connect_provider_url = "https://xyz"
  

// To automatically update the EKS node AMI image when updating EKS, you can use the following variable and remove the ami_id from your node_pools configuration:

 # eks_ami_release_version = "1.28.8-20240703" 
  

  node_pools = [
    {
      name                  = "karpenter-nodepool-1"
      ami_id                = "ami-12345678"  # This is being manually specified
      subnet_discovery_tag  = "cluster1"
      tags = {
        environment_name          = "dev"
        instanceName              = "Karpenter-cluster1"
        # "cost-control:purpose"  = "testing"
        owner                     = "user1"
      }
    },
    # {
    #  name                  = "karpenter-nodepool-2"
    #  ami_id                = "ami-87654321"  # This is being manually specified
    #  subnet_discovery_tag  = "cluster2"
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

##### Outputs

This module does not have any outputs.

##### Providers

- `aws` - The AWS provider.
- `helm` - The Helm provider.
