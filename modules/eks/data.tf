data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

data "aws_iam_openid_connect_provider" "eks" {
  url = module.eks.cluster_oidc_issuer_url
}
