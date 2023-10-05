output "secrets_id" {
  value       = [for secret in azurerm_key_vault_secret.main : zipmap([secret.name], [secret.id])]
  description = "The Key Vault Secret ID."
}

output "secrets_resource_id" {
  value       = [for secret in azurerm_key_vault_secret.main : zipmap([secret.name], [secret.resource_id])]
  description = <<EOF
    The (Versioned) ID for this Key Vault Secret. This property points to a specific version of a Key Vault Secret, 
    as such using this won't auto-rotate values if used in other Azure Services.
  EOF
}

output "keys_id" {
  value       = [for key in azurerm_key_vault_key.main : zipmap([key.name], [key.id])]
  description = "The Key Vault Key ID."
}

output "keys_resource_id" {
  value       = [for key in azurerm_key_vault_key.main : zipmap([key.name], [key.resource_id])]
  description = <<EOF
    The (Versioned) ID for this Key Vault Key. This property points to a specific version of a Key Vault Key,
    as such using this won't auto-rotate values if used in other Azure Services.
  EOF
}

output "certificates_id" {
  value       = [for certificate in azurerm_key_vault_certificate.main : zipmap([certificate.name], [certificate.id])]
  description = "The Key Vault Certificate ID."
}

output "certificates_version" {
  value       = [for certificate in azurerm_key_vault_certificate.main : zipmap([certificate.name], [certificate.version])]
  description = "The current version of the Key Vault Certificate."
}

output "certificates_thumbprint" {
  value       = [for certificate in azurerm_key_vault_certificate.main : zipmap([certificate.name], [certificate.thumbprint])]
  description = "The X509 Thumbprint of the Key Vault Certificate represented as a hexadecimal string."
}