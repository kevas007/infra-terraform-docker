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
  description = "Chemin vers la clé privée SSH (ex: C:\\Users\\kevAs\\.ssh\\id_rsa_terra)"
  type        = string

  default     = "C:/Users/kevAs/.ssh/id_rsa"
}

variable "allowed_ip" {
  description = "Adresse IP autorisée pour la connexion SSH et l'accès à l'API Docker"
  type        = string
}

variable "dirs" {
  description = "Liste des dossiers à créer sur le serveur"
  type        = list(string)
}

variable "network_name" {
  description = "Nom du réseau Docker à créer"
  type        = string

}

variable "mysql_root_password" {
  description = "Mot de passe root pour MySQL (passé en variable d'environnement au conteneur)"
  type        = string
  sensitive   = true
}
