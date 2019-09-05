provider "digitalocean" {}

resource "digitalocean_ssh_key" "om" {
  name       = "om ssh key"
  public_key = "${file("/Users/Cadey/.ssh/id_ed25519.pub")}"
}

resource "digitalocean_kubernetes_cluster" "main" {
  name    = "kubermemes"
  region  = "${var.region}"
  version = "${var.kubernetes_version}"

  node_pool {
    name       = "worker-pool"
    size       = "${var.node_size}"
    node_count = 2
  }
}

resource "local_file" "kubeconfig" {
  content  = "${digitalocean_kubernetes_cluster.main.kube_config.0.raw_config}"
  filename = "${path.module}/.kubeconfig"
}
