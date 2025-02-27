resource "helm_release" "karpenter_crd" {
  name       = "karpente-crd"
  namespace  = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter-crd"
  version    = "1.2.1"

  create_namespace = true

  wait = true
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.2.1"

  create_namespace = true

  values = [
    file("./helm/karpenter_values.yaml")
  ]

  wait = true

  depends_on = [helm_release.karpenter_crd]
}

locals {
  yamls = split("---", file("./provisioners/karpenter.yaml"))
}

resource "kubernetes_manifest" "provisioner" {
  for_each = { for idx, doc in local.yamls : idx => yamldecode(doc) }

  manifest = each.value
}
