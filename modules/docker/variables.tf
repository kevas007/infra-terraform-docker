variable "name" {
  description = "Nom du conteneur Docker"
  type        = string
}
variable "image" {
  description = "Image Docker à déployer (ex: nginx:latest)"
  type        = string
}
variable "container_port" {
  description = "Port interne exposé par le conteneur"
  type        = number
}
variable "host_port" {
  description = "Port sur le serveur hôte mappé au port interne du conteneur"
  type        = number
}
variable "network_name" {
  description = "Nom du réseau Docker auquel attacher le conteneur"
  type        = string
}
variable "env_vars" {
  description = "Variables d'environnement pour le conteneur (clé=valeur)"
  type        = map(string)
  default     = {}
}
variable "volumes" {
  description = "Volumes à monter dans le conteneur (liste d'objets host_path/container_path)"
  type = list(object({
    host_path      = string
    container_path = string
  }))
  default = []
}
