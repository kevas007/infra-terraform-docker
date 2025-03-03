output "network_name" {
  value = docker_network.backend.name
  description = "The name of the Docker backend network"
}

output "folders_created" {
  value = null_resource.create_folders.id
  description = "ID of the resource that creates the necessary folders"
}