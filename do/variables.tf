variable "region" {
  type    = "string"
  default = "nyc3"
}

variable "kubernetes_version" {
  type    = "string"
  default = "1.15.3-do.1"
}

variable "node_size" {
  type    = "string"
  default = "s-1vcpu-2gb"
}

variable "do_token" {}
