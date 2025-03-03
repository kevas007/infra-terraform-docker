terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "tcp://${var.server_host}:2375"
}

module "docker" {
  source   = "./modules/docker"
  vpn_host = var.vpn_host
}

module "authelia" {
  source = "./modules/authelia"
  network_name = module.docker.network_name
  folders_created = module.docker.folders_created
}

module "ldap" {
  source = "./modules/ldap"
  network_name = module.docker.network_name
  folders_created = module.docker.folders_created
}
