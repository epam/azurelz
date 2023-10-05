output "id" {
  description = "The id of the newly created Azure Firewall"
  value       = azurerm_firewall.firewall.id
}

output "name" {
  description = "The Name of the newly created Azure Firewall"
  value       = azurerm_firewall.firewall.name
}

output "ip_configuration_private_ip_address" {
  description = "The IP configuration private IP address of the newly created Azure Firewall"
  value       = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}