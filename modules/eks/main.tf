module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.32"
  subnet_ids      = var.subnets
  vpc_id          = var.vpc_id

  enable_cluster_creator_admin_permissions = true

  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = [
    "105.163.158.69/32",
  ]

  enable_irsa = true

  eks_managed_node_groups = {
    karpenter = {
      instance_types = ["t3.small"]
      desired_size   = 1
      min_size       = 1
      max_size       = 1
      capacity_type  = "SPOT"
      labels = {
        "role" = "karpenter"
      }
    }
  }
}

module "karpenter" {
  source       = "terraform-aws-modules/eks/aws//modules/karpenter"
  cluster_name = module.eks.cluster_name
  namespace    = "karpenter"

  create_access_entry = false

  create_iam_role = false
  iam_role_name   = "KarpenterServiceAccountRole"

  enable_irsa                     = true
  irsa_namespace_service_accounts = ["karpenter:karpenter"]
  irsa_oidc_provider_arn          = module.eks.cluster_oidc_issuer_url

  create_node_iam_role = false
  node_iam_role_arn    = module.eks.eks_managed_node_groups["karpenter"].iam_role_arn

  depends_on = [module.eks_karpenter_namespaces_sa_role]
}
