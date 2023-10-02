output "role_id" {
  description = "The Role Definition ID"
  value       = var.definition != null ? azurerm_role_definition.definition[0].role_definition_id : null
}

output "role_resource_id" {
  description = "The Azure Resource Manager ID for the role definition"
  value       = var.definition != null ? azurerm_role_definition.definition[0].role_definition_resource_id : null
}
