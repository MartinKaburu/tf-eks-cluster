output "karpenter_crd_helm_status" {
  value = helm_release.karpenter_crd.status
}

output "karpenter_helm_status" {
  value = helm_release.karpenter.status
}
