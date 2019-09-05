resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "external_dns" {
  metadata {
    name = "external-dns"
  }

  data = {
    cf_email = "${var.cf_email}"
    cf_token = "${var.cf_token}"
  }
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "external-dns"
  }
}

resource "kubernetes_cluster_role" "external_dns" {
  metadata {
    name = "external-dns"
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["list"]
  }
}

resource "kubernetes_cluster_role_binding" "external_dns_viewer" {
  metadata {
    name = "external-dns-viewer"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "external-dns"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "external-dns"
    namespace = "external-dns"
  }
}

resource "null_resource" "external_dns_deployment" {
  triggers = {
    role_binding = "${kubernetes_cluster_role_binding.external_dns_viewer.metadata[0].uid}"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local_file.kubeconfig.filename} apply -f ${path.module}/external_dns.yaml"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kubectl --kubeconfig ${local_file.kubeconfig.filename} delete -f ${path.module}/external_dns.yaml"
  }
}
