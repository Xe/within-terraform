provider "kubernetes" {
  config_path = "${local_file.kubeconfig.filename}"
}

resource "kubernetes_namespace" "apps" {
  metadata {
    name = "apps"
  }
}
