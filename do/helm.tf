provider "helm" {
  service_account = "${kubernetes_service_account.tiller.metadata[0].name}"

  kubernetes {
    config_path = "${local_file.kubeconfig.filename}"
  }
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller-hack"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "null_resource" "helm_hack" {
  triggers = {
    role_binding = "${kubernetes_cluster_role_binding.tiller.metadata[0].uid}"
  }

  provisioner "local-exec" {
    command = "helm init --kubeconfig ${local_file.kubeconfig.filename} --upgrade --service-account ${kubernetes_service_account.tiller.metadata[0].name} --force-upgrade"
  }
}

resource "helm_release" "nginx" {
  name       = "nginx-ingress"
  repository = ""
  chart      = "stable/nginx-ingress"
  version    = "1.19.0"

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }
}
