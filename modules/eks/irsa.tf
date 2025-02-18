module "eks_karpenter_namespaces_sa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "= 5.52.2"

  role_name = "KarpenterServiceAccountRole"

  # Federated Policy
  oidc_providers = {
    external-secrets = {
      provider_arn = data.aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = [
        # ns:sa
        "karpenter:karpenter"
      ]
    }
  }

  role_policy_arns = {
    AmazonEC2FullAccess     = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    AmazonSSMReadOnlyAccess = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
    AmazonEKSWorkerNodePolicy = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    AmazonEKSClusterPolicy  = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  }

  depends_on = [module.eks]
}
