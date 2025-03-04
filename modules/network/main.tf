terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

resource "docker_network" "network" {
  name     = var.network_name
  driver   = "bridge"
  internal = true
}

output "network_name" {
  value = docker_network.network.name
}
