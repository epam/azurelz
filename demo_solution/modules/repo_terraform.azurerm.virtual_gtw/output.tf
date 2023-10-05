output "id" {
  description = "The ID of the Local Network Gateway"
  value       = azurerm_virtual_network_gateway.virtual_gateway.id
}

output "name" {
  description = "The name of the Local Network Gateway"
  value       = azurerm_virtual_network_gateway.virtual_gateway.name
}

output "bgp_peering_address" {
  description = "The bgp peering ip address of the Local Network Gateway"
  value       = try(azurerm_virtual_network_gateway.virtual_gateway.bgp_settings[0].peering_addresses[0].default_addresses[0], null)
}

output "connection_id" {
  description = "The ID of the connection created between this and the remote gateway"
  value       = var.connection != null ? azurerm_virtual_network_gateway_connection.connection[0].id : null
}

output "local_network_gateway_id" {
  description = "The ID of the Local Network Gateway"
  value       = var.local_network_gateway != null ? azurerm_local_network_gateway.onprem[0].id : null
}
