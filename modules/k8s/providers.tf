provider "kubernetes" {
  host                   = data.terraform_remote_state.eks_state.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks_state.outputs.cluster_certificate_authority_data)
  token                  = data.terraform_remote_state.eks_state.outputs.aws_eks_cluster_auth
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks_state.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks_state.outputs.cluster_certificate_authority_data)
    token                  = data.terraform_remote_state.eks_state.outputs.aws_eks_cluster_auth
  }
}
