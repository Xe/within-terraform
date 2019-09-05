resource "kubernetes_role" "helm_hack" {
  metadata {
    name      = "helm-hack"
    namespace = "kube-system"
  }

  rule {
    api_groups = [
      "*",
    ]
    resources = [
      "*",
    ]
    verbs = [
      "*",
    ]
  }
}

resource "kubernetes_role_binding" "helm_hack" {
  metadata {
    name      = "helm-hack"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "helm-hack"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
}
