module "server" {
  source = "../../modules/server"

  droplet_name      = "watchlist-prod"
  size              = var.droplet_size
  region            = var.region
  ssh_key_id        = var.ssh_key_id
  deploy_public_key = var.deploy_public_key
}

module "networking" {
  source = "../../modules/networking"

  region     = var.region
  droplet_id = module.server.droplet_id
}
