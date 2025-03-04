terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "tcp://${var.server_host}:2375"
}

# Module de préparation du serveur (SSH + création dossiers)
module "server_setup" {
  source               = "./modules/server_setup"
  server_host          = var.server_host
  ssh_user             = var.ssh_user
  ssh_private_key_path = var.ssh_private_key_path
  allowed_ip           = var.allowed_ip
  dirs                 = ["/home/ubuntu/nginx_data", "/home/ubuntu/mysql_data"]
  mysql_root_password  = var.mysql_root_password
  network_name         = var.network_name
  admin_password       = var.admin_password  
}

# Module de réseau Docker (création d'un réseau Docker pour les conteneurs)
module "network" {
  source       = "./modules/network"
  network_name = var.network_name
}

# Module de déploiement du conteneur Nginx
module "nginx_container" {
  source         = "./modules/docker"
  name           = "nginx"
  image          = "nginx:latest"
  container_port = 8081
  host_port      = 8081
  network_name   = module.network.network_name
  volumes = [{
    host_path      = "/home/ubuntu/nginx_data",
    container_path = "/usr/share/nginx/html"
  }]
  depends_on = [module.server_setup]
}

# Module de déploiement du conteneur MySQL
module "mysql_container" {
  source         = "./modules/docker"
  name           = "mysql"
  image          = "mysql:latest"
  container_port = 3306
  host_port      = 3306
  network_name   = module.network.network_name
  env_vars = {
    MYSQL_ROOT_PASSWORD = var.mysql_root_password
  }
  volumes = [{
    host_path      = "/home/ubuntu/mysql_data",
    container_path = "/var/lib/mysql"
  }]
  depends_on = [module.server_setup]
}
