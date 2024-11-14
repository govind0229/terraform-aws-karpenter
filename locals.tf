// Create a local variable to store the AMI query
locals {
    eks_ami_query = var.eks_ami_release_version != null ? "${split(".", var.eks_ami_release_version)[0]}.${split(".", var.eks_ami_release_version)[1]}-v${split("-", var.eks_ami_release_version)[1]}" : null
}

