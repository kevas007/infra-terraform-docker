terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

resource "docker_container" "authelia" {
  name  = "authelia-terraform"
  image = "authelia/authelia:latest"
  restart = "always"
  must_run = true
  depends_on = [var.folders_created]

  ports {
    internal = 9091
    external = 9091
  }

  volumes {
    host_path      = "/home/ubuntu/config/authelia"
    container_path = "/config"
  }

  networks_advanced {
    name = var.network_name
  }
}
