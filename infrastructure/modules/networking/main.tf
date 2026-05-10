resource "digitalocean_reserved_ip" "main" {
  region = var.region
}

resource "digitalocean_reserved_ip_assignment" "main" {
  ip_address = digitalocean_reserved_ip.main.ip_address
  droplet_id = var.droplet_id
}
