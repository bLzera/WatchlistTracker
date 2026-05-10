variable "do_token" {
  description = "Token de API do DigitalOcean"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Região do DigitalOcean"
  type        = string
  default     = "nyc1"
}

variable "droplet_size" {
  description = "Tamanho do Droplet"
  type        = string
  default     = "s-2vcpu-2gb"
}

variable "ssh_key_id" {
  description = "ID (fingerprint) da chave SSH cadastrada no DigitalOcean"
  type        = string
}

variable "deploy_public_key" {
  description = "Chave pública SSH para o usuário deploy no servidor"
  type        = string
}
