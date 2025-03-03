resource "null_resource" "create_folders" {
  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.server_host
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/nginx",
      "mkdir -p /home/ubuntu/config/nginx",
      "mkdir -p /home/ubuntu/config/authelia",
      "mkdir -p /home/ubuntu/config/ldap"
    ]
  }

  triggers = {
    always_run = "${timestamp()}"  # Force l'exécution à chaque `terraform apply`
  }
}
