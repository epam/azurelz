output "id" {
  value       = azurerm_key_vault.main.id
  description = "The ID of the Key Vault."
}

output "name" {
  value       = azurerm_key_vault.main.name
  description = "The name of the Key Vault."
}

output "uri" {
  value       = azurerm_key_vault.main.vault_uri
  description = "The URI of the Key Vault."
}
