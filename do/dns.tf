provider "cloudflare" {}

resource "cloudflare_record" "public_dns" {
  domain = "within.website"
  name   = "cipra-${terraform.workspace}"
  value  = "${digitalocean_droplet.cipra.ipv4_address}"
  type   = "A"
  ttl    = 120
}
