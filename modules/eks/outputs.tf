output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "aws_eks_cluster_auth" {
  value = data.aws_eks_cluster_auth.eks.token

  sensitive = true
}
