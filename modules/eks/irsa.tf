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
    AmazonEC2FullAccess        = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"

  }

  depends_on = [module.eks]
}

#resource "aws_iam_policy" "karpenter_eks_access" {
#  name        = "karpenter_eks_access_policy"
#  description = "Allows EKS cluster access"
#  policy      = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Effect   = "Allow"
#        Action   = [
#          "eks:*",
#        ]
#
#        Resource = "*"
#      }
#    ]
#  })
#}
#
#resource "aws_iam_role_policy_attachment" "eks_access_attach" {
#  policy_arn = aws_iam_policy.karpenter_eks_access.arn
#  role       = "KarpenterServiceAccountRole"
#}
