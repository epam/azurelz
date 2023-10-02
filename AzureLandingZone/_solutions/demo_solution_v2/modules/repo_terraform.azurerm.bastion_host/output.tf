output "id" {
  description = "The ID of the Bastion Host"
  value       = azurerm_bastion_host.bastion.id
}

output "dns_name" {
  description = "The FQDN for the Bastion Host."
  value       = azurerm_bastion_host.bastion.dns_name
}