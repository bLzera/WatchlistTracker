output "droplet_id" {
  description = "ID do Droplet"
  value       = digitalocean_droplet.main.id
}

output "droplet_ip" {
  description = "IP público do Droplet (antes de associar o Reserved IP)"
  value       = digitalocean_droplet.main.ipv4_address
}
