provider "digitalocean" {}

resource "digitalocean_ssh_key" "om" {
  name       = "Cadey main SSH key"
  public_key = "${file("/Users/Cadey/.ssh/id_ed25519.pub")}"
}

resource "digitalocean_droplet" "cipra" {
  image  = "coreos-stable"
  name   = "cipra-${terraform.workspace}"
  region = "nyc3"
  size   = "s-1vcpu-2gb"
  ssh_keys = ["${digitalocean_ssh_key.om.fingerprint}"]
}

resource "digitalocean_project" "workspace" {
  name        = "cipra-bakfu-${terraform.workspace}"
  description = "lo cipra bakfu be zo ${terraform.workspace}"
  purpose     = "Web Application"
  environment = "Development"
  resources   = ["${digitalocean_droplet.cipra.urn}"]
}
