output "id" {
  description = "The user assigned identity ID"
  value       = azurerm_user_assigned_identity.user_assigned_identity.id
}

output "principal_id" {
  description = "Service Principal ID associated with the user assigned identity"
  value       = azurerm_user_assigned_identity.user_assigned_identity.principal_id
}

output "client_id" {
  description = "Client ID associated with the user assigned identity"
  value       = azurerm_user_assigned_identity.user_assigned_identity.client_id
}

output "tenant_id" {
  description = "Tenant ID associated with the user assigned identity"
  value       = azurerm_user_assigned_identity.user_assigned_identity.tenant_id
}

