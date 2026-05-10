resource "digitalocean_droplet" "main" {
  name     = var.droplet_name
  size     = var.size
  image    = "ubuntu-22-04-x64"
  region   = var.region
  ssh_keys = [var.ssh_key_id]

  user_data = templatefile("${path.module}/cloud-init.yaml.tpl", {
    deploy_public_key = var.deploy_public_key
  })

  tags = ["watchlist", var.droplet_name]
}

resource "digitalocean_firewall" "main" {
  name        = "${var.droplet_name}-firewall"
  droplet_ids = [digitalocean_droplet.main.id]

  # SSH restrito ao IP de administração (ou 0.0.0.0/0 para simplificar inicialmente)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
