variable "server_host" {
  description = "Adresse IP ou nom d'hôte du serveur Docker distant"
  type        = string
}

variable "ssh_user" {
  description = "Utilisateur SSH pour se connecter au serveur"
  type        = string
  default     = "ubuntu"
}

variable "ssh_private_key_path" {
  description = "Chemin vers la clé privée SSH"
  type        = string
}

variable "allowed_ip" {
  description = "Adresse IP autorisée pour la connexion SSH et l'accès à l'API Docker"
  type        = string
}

variable "network_name" {
  description = "Nom du réseau Docker à créer"
  type        = string
  default     = ""
}


variable "mysql_root_password" {
  description = "Mot de passe root pour MySQL (passé au conteneur MySQL)"
  type        = string
  sensitive   = true
}
variable "admin_password" {
  description = "Mot de passe pour l'élévation sudo sur le serveur"
  type        = string
  sensitive   = true
}
