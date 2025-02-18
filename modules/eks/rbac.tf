#resource "aws_eks_access_entry" "martin" {
#  cluster_name = module.eks.cluster_name
#  principal_arn = "arn:aws:iam::594683469266:user/martin"
#
#  kubernetes_groups = ["cluster-admins"]
#  type              = "STANDARD"
#}

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
