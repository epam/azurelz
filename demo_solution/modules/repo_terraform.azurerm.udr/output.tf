output "id" {
  description = "The Route Table ID"
  value       = azurerm_route_table.route_table.id
}

output "name" {
  description = "The Route Table name"
  value       = azurerm_route_table.route_table.name
}
