provider "digitalocean" {}

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
