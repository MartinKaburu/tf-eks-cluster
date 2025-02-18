resource "helm_release" "karpenter_crd" {
  name       = "karpente-crd"
  namespace  = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter-crd"
  version    = "1.2.1"

  create_namespace = true

  wait       = true
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

  wait       = true

  depends_on = [helm_release.karpenter_crd]
}

resource "kubernetes_manifest" "provisioner" {
  for_each = fileset("./provisioners", "*.yaml")

  manifest = yamldecode(file(format("%s%s", "./provisioners/", each.value)))

  depends_on = [helm_release.karpenter]
}
