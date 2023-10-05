output "id" {
  value       = azurerm_private_endpoint.endpoint.id
  description = "The ID of the Private Endpoint."
}

output "fqdn" {
  value       = try(azurerm_private_endpoint.endpoint.custom_dns_configs[0].fqdn, null)
  description = "The fully qualified domain name to the private_endpoint."
}

output "ip_address" {
  value       = try(azurerm_private_endpoint.endpoint.private_service_connection[0].private_ip_address, null)
  description = "A list of all IP Addresses that map to the private_endpoint fqdn."
}

output "ip_configuration" {
  value       = try(azurerm_private_endpoint.endpoint.ip_configuration, {})
  description = "An ip_configuration block."
}

output "private_dns_zone_group" {
  value       = try(azurerm_private_endpoint.endpoint.private_dns_zone_group, {})
  description = "An private_dns_zone_group block."
}
