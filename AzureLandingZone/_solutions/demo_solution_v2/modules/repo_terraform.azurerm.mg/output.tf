output "id" {
  description = "The ID of the Management Group"
  value       = azurerm_management_group.mg.id
}

output "display_name" {
  description = "The displey name of the Management Group"
  value       = azurerm_management_group.mg.display_name
}

output "name" {
  description = "The name of the Management Group"
  value       = azurerm_management_group.mg.name
}