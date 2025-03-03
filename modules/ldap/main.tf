terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

resource "docker_container" "ldap" {
  name  = "openldap-terraform"
  image = "osixia/openldap:latest"
  restart = "always"
  must_run = true
  depends_on = [var.folders_created]

  env = [
    "LDAP_ORGANISATION=Example Organization",
    "LDAP_DOMAIN=example.com",
    "LDAP_ADMIN_PASSWORD=admin",
    "LDAP_CONFIG_PASSWORD=config",
    "LDAP_READONLY_USER=true",
    "LDAP_READONLY_USER_USERNAME=readonly",
    "LDAP_READONLY_USER_PASSWORD=readonly"
  ]

  volumes {
    host_path      = "/home/ubuntu/config/ldap"
    container_path = "/etc/ldap"
  }

  networks_advanced {
    name = var.network_name
  }
}
