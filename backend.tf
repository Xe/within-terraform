terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "nenri"

    workspaces {
      prefix = "cipra-"
    }
  }
}
