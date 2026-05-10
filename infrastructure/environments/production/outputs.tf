output "server_ip" {
  description = "IP estático reservado — aponte seu DNS aqui"
  value       = module.networking.reserved_ip
}

output "droplet_id" {
  description = "ID do Droplet"
  value       = module.server.droplet_id
}
