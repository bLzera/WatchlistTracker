terraform {
  required_version = ">= 1.6"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.40"
    }
  }

  # Estado remoto em DigitalOcean Spaces (S3-compatible)
  # Configure as credenciais via env antes de rodar terraform init:
  #   export AWS_ACCESS_KEY_ID=<spaces-access-key>
  #   export AWS_SECRET_ACCESS_KEY=<spaces-secret-key>
  backend "s3" {
    bucket                      = "watchlist-tf-state"
    key                         = "production/terraform.tfstate"
    endpoint                    = "https://nyc3.digitaloceanspaces.com"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    force_path_style            = true
  }
}

provider "digitalocean" {
  token = var.do_token
}
