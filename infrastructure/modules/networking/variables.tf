variable "region" {
  description = "Região do Reserved IP"
  type        = string
  default     = "nyc1"
}

variable "droplet_id" {
  description = "ID do Droplet ao qual associar o IP reservado"
  type        = number
}
