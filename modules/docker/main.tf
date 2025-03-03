terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

resource "null_resource" "create_folders" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      docker run --rm -v /home/ubuntu:/home/ubuntu alpine:latest /bin/sh -eux <<'SCRIPT_EOF'
      # Crée les dossiers requis
      mkdir -p /home/ubuntu/nginx \
               /home/ubuntu/config/nginx \
               /home/ubuntu/config/authelia \
               /home/ubuntu/config/ldap/slapd.d

      # Création de la config Nginx si elle n'existe pas
      if [ ! -f /home/ubuntu/config/nginx/nginx.conf ]; then
        cat <<'NGINX_EOF' > /home/ubuntu/config/nginx/nginx.conf
events { worker_connections 1024; }
http {
  server {
    listen 80;
    server_name localhost;
    location / {
      root /usr/share/nginx/html;
      index index.html;
    }
  }
}
NGINX_EOF
      fi

      # Création de la config Authelia si elle n'existe pas
      if [ ! -f /home/ubuntu/config/authelia/config.yml ]; then
        cat <<'AUTHELIA_EOF' > /home/ubuntu/config/authelia/config.yml
host: 0.0.0.0
port: 9091
log_level: debug
jwt_secret: a_very_important_secret
default_redirection_url: http://localhost
server:
  path: /
  tls:
    key: /path/to/key
    certificate: /path/to/cert
totp:
  issuer: authelia.com
authentication_backend:
  file:
    path: /config/users_database.yml
session:
  name: authelia_session
  secret: unsecure_session_secret
  expiration: 3600
  inactivity: 300
  domain: localhost
regulation:
  max_retries: 3
  find_time: 120
  ban_time: 300
storage:
  local:
    path: /config/db.sqlite3
notifier:
  filesystem:
    filename: /config/notifications.txt
AUTHELIA_EOF
      fi

      # Création du fichier users_database.yml si absent
      if [ ! -f /home/ubuntu/config/authelia/users_database.yml ]; then
        cat <<'USERS_EOF' > /home/ubuntu/config/authelia/users_database.yml
users:
  admin:
    displayname: "Admin User"
    password: "$argon2id\$v=19\$m=65536,t=3,p=4\$c29tZXNhbHQ\$RdescudvJCsgt3ub+b+dWRWJTmaaJObG"
    email: admin@example.com
    groups:
      - admins
USERS_EOF
      fi

      # Création de fichiers vides et réglage des permissions
      touch /home/ubuntu/config/authelia/db.sqlite3
      touch /home/ubuntu/config/authelia/notifications.txt
      chmod 600 /home/ubuntu/config/authelia/db.sqlite3
      chmod -R 700 /home/ubuntu/config/ldap
SCRIPT_EOF
    EOT
    interpreter = ["bash", "-c"]
  }
}

resource "docker_network" "backend" {
  name = "backend"
}

resource "docker_container" "nginx" {
  name      = "nginx"
  image     = "nginx:latest"
  restart   = "always"
  depends_on = [null_resource.create_folders]

  ports {
    internal = 80
    external = 80
  }

  volumes {
    host_path      = "/home/ubuntu/config/nginx"
    container_path = "/etc/nginx"
  }

  networks_advanced {
    name = docker_network.backend.name
  }
}

resource "docker_container" "authelia" {
  name      = "authelia"
  image     = "authelia/authelia:latest"
  restart   = "always"
  depends_on = [null_resource.create_folders]

  volumes {
    host_path      = "/home/ubuntu/config/authelia"
    container_path = "/config"
  }

  networks_advanced {
    name = docker_network.backend.name
  }
}

resource "docker_container" "ldap" {
  name      = "openldap"
  image     = "osixia/openldap:latest"
  restart   = "always"
  depends_on = [null_resource.create_folders]

  env = [
    "LDAP_ORGANISATION=Example Organization",
    "LDAP_DOMAIN=localhost",
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
    name = docker_network.backend.name
  }
}
