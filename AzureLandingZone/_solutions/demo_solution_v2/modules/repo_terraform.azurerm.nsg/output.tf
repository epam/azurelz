output "nsg_id" {
  description = "The ID of the Network Security Group"
  value       = azurerm_network_security_group.nsg.id
}

output "nsg_name" {
  description = "The Name of the Network Security Group"
  value       = azurerm_network_security_group.nsg.name
}
