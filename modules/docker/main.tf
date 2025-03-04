terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

# Récupération de l'image Docker
resource "docker_image" "image" {
  name = var.image
}

# Déploiement du conteneur Docker
resource "docker_container" "container" {
  name  = var.name
  image = docker_image.image.name

  # Attachement au réseau Docker
  networks_advanced {
    name = var.network_name
  }

  # Mapping des ports hôte et conteneur
  ports {
    internal = var.container_port
    external = var.host_port
    ip       = "0.0.0.0"
  }

  # Variables d'environnement
  env = [for k, v in var.env_vars : "${k}=${v}"]

  # Montage des volumes
  dynamic "volumes" {
    for_each = var.volumes
    content {
      host_path      = volumes.value.host_path
      container_path = volumes.value.container_path
    }
  }

  restart = "unless-stopped"
}
