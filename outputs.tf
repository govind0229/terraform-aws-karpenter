// Outputs
output "eks_amd_ami_id" {
  value = data.aws_ami.eks_ami.id
}
