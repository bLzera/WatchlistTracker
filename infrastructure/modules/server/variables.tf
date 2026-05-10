variable "droplet_name" {
  description = "Nome do Droplet"
  type        = string
}

variable "size" {
  description = "Tamanho do Droplet (ex: s-2vcpu-2gb)"
  type        = string
  default     = "s-2vcpu-2gb"
}

variable "region" {
  description = "Região do Droplet"
  type        = string
  default     = "nyc1"
}

variable "ssh_key_id" {
  description = "ID da SSH key registrada no DigitalOcean"
  type        = string
}

variable "deploy_public_key" {
  description = "Chave pública SSH para o usuário deploy (gerada pelo GitHub Actions)"
  type        = string
}
