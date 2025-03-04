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

# Sécurisation de SSH sur le serveur
resource "null_resource" "secure_ssh" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = var.server_host
      private_key = file(var.ssh_private_key_path)
      timeout     = "60s"
    }
   inline = [
      "echo '🔐 Sécurisation de SSH en cours...'",
      "echo '${var.admin_password}' | sudo -S sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config",
      "echo '${var.admin_password}' | sudo -S sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config",
      "echo 'AllowUsers ${var.ssh_user}@${var.allowed_ip}' | sudo tee -a /etc/ssh/sshd_config",
      "echo '${var.admin_password}' | sudo -S systemctl restart sshd",
      "echo '✅ SSH sécurisé.'"
    ]
  }
}

# Configuration du firewall (UFW)
resource "null_resource" "setup_firewall" {
  depends_on = [null_resource.secure_ssh]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = var.server_host
      private_key = file(var.ssh_private_key_path)
      timeout     = "60s"
    }
    inline = [
      "echo '🛡️ Configuration du firewall UFW...'",
      "echo '${var.admin_password}' | sudo -S apt update && sudo -S apt install -y ufw",
      "echo '${var.admin_password}' | sudo -S ufw allow 22/tcp",
      "echo '${var.admin_password}' | sudo -S ufw allow 80/tcp",
      "echo '${var.admin_password}' | sudo -S ufw allow 3306/tcp",
      "echo '${var.admin_password}' | sudo -S ufw allow from ${var.allowed_ip} to any port 2375",
      "echo '${var.admin_password}' | sudo -S ufw default deny incoming",
      "echo '${var.admin_password}' | sudo -S ufw default allow outgoing",
      "echo '${var.admin_password}' | sudo -S ufw --force enable",
      "echo '✅ Firewall UFW configuré.'"
    ]
  }
}

# Installation et configuration de Fail2Ban
resource "null_resource" "install_fail2ban" {
  depends_on = [null_resource.setup_firewall]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = var.server_host
      private_key = file(var.ssh_private_key_path)
      timeout     = "60s"
    }
    inline = [
      "echo '🚨 Installation de Fail2Ban...'",
      "sudo apt install -y fail2ban",
      "sudo systemctl enable fail2ban",
      "sudo systemctl start fail2ban",
      "echo '✅ Fail2Ban installé et activé.'"
    ]
  }
}

# Création des dossiers requis sur le serveur, uniquement s'ils n'existent pas
resource "null_resource" "create_dirs" {
  depends_on = [null_resource.install_fail2ban]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = var.server_host
      private_key = file(var.ssh_private_key_path)
      timeout     = "60s"
    }
    inline = [
      "echo '📁 Vérification et création des dossiers sur le serveur...'",
      "for dir in ${join(" ", var.dirs)}; do",
      "  if [ ! -d \"$dir\" ]; then",
      "    echo \"📂 Création du dossier : $dir\"",
      "    mkdir -p \"$dir\"",
      "  else",
      "    echo \"✅ Le dossier existe déjà : $dir\"",
      "  fi",
      "done",
      "echo '✅ Vérification terminée.'"
    ]
  }
}
