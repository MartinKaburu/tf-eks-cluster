module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.28"
  subnet_ids      = var.subnets
  vpc_id          = var.vpc_id

  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = [
      "105.163.158.69/32",
  ]

  enable_irsa     = true

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
      taints = [{
        key    = "role"
        value  = "karpenter"
        effect = "NO_SCHEDULE"
      }]
    }
  }
}

module "karpenter" {
  source               = "terraform-aws-modules/eks/aws//modules/karpenter"
  cluster_name         = module.eks.cluster_name
  namespace            = "karpenter"

  create_access_entry  = false

  create_iam_role      = false
  iam_role_name        = "KarpenterServiceAccountRole"

  enable_irsa          = true
  irsa_namespace_service_accounts = ["karpenter:karpenter"]
  irsa_oidc_provider_arn = module.eks.cluster_oidc_issuer_url

  create_node_iam_role = false
  node_iam_role_arn    = module.eks.eks_managed_node_groups["karpenter"].iam_role_arn

  depends_on = [module.eks_karpenter_namespaces_sa_role]
}

resource "aws_eks_access_entry" "martin" {
  cluster_name = module.eks.cluster_name
  principal_arn = "arn:aws:iam::594683469266:user/martin"

  kubernetes_groups = ["system:masters"]
  type              = "STANDARD"
}

resource "kubernetes_cluster_role" "cluster_admin" {
  metadata {
    name = "cluster-admins-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_admin_binding" {
  metadata {
    name = "cluster-admins-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_admin.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "cluster-admins"
    api_group = "rbac.authorization.k8s.io"
  }
}
