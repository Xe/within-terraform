data "google_compute_image" "cos_image" {
  family  = "cos-stable"
  project = "cos-cloud"
}

resource "google_compute_instance" "default" {
  name         = "cipra-sampu-${terraform.workspace}"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  tags = ["defaultssh"]

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.cos_image.self_link}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    block-project-ssh-keys = "TRUE"
    ssh-keys               = <<-EOF
      cadey:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDsviqiUuN6t4YM2H+ApQtGAFx6TWJbWCqDDhInIh3X40ZAxtTmryRwAXdtHJ+v6HuGFU5XH3chDX1WSRbwVIrlxkX1hJIEZO379YSIHkORSrAmxF/2lsrW2zSjufZ6IS9yI7nsxe2mJf3GEiFjoAh2iGrSKnOACK2Y+o/SiO0BtDkOUIabofuAxf/RNOpn/HSPh/MabOxYuNOMO2bl+quYN7C1idyvVcNp0llfrnGGTCk5g3rDpR+CDQ0P2Ebg1hf4j2i/6XJmHL52Zg4b8hkoS9BzRcb2vOjGYZVR4lOMqR9ZcNMUBwMboJeQtsAib9DYaGjhMWgMQ76brXwE65sX cadey
    EOF
  }
}
