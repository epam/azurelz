output "name" {
  description = "The name of the Public IP resource"
  value       = azurerm_public_ip.public_ip.name
}

output "id" {
  description = "The ID of this Public IP."
  value       = azurerm_public_ip.public_ip.id
}

output "ip_address" {
  description = "The IP address value that was allocated."
  value       = azurerm_public_ip.public_ip.ip_address
}

output "fqdn" {
  description = "Fully qualified domain name of the A DNS record associated with the public IP."
  value       = azurerm_public_ip.public_ip.fqdn
}