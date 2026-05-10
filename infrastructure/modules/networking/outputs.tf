output "reserved_ip" {
  description = "IP estático reservado (use este para apontar o DNS)"
  value       = digitalocean_reserved_ip.main.ip_address
}
