terraform {
  required_version = ">= 1.6"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.40"
    }
  }

  # State local — terraform.tfstate fica em infrastructure/environments/production/
  # Está no .gitignore (não commitar — pode conter dados sensíveis).
  # Faça backup manual do arquivo após cada terraform apply (ex: copie para
  # um local seguro fora do repositório).
}

provider "digitalocean" {
  token = var.do_token
}
