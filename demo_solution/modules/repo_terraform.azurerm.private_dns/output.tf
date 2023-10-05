output "id" {
  value       = azurerm_private_dns_zone.private_dns.id
  description = "The Private DNS Zone ID"
}

output "soa_record" {
  value       = try(azurerm_private_dns_zone.private_dns.soa_record, null)
  description = "An SOA record block"
}

output "number_of_record_sets" {
  value       = try(azurerm_private_dns_zone.private_dns.number_of_record_sets, null)
  description = "The current number of record sets in this Private DNS zone."
}

output "max_number_of_record_sets" {
  value       = try(azurerm_private_dns_zone.private_dns.max_number_of_record_sets, null)
  description = "The maximum number of record sets that can be created in this Private DNS zone."
}

output "max_number_of_virtual_network_links" {
  value       = try(azurerm_private_dns_zone.private_dns.max_number_of_virtual_network_links, null)
  description = "The maximum number of virtual networks that can be linked to this Private DNS zone."
}

output "max_number_of_virtual_network_links_with_registration" {
  value       = try(azurerm_private_dns_zone.private_dns.max_number_of_virtual_network_links_with_registration, null)
  description = "The maximum number of virtual networks that can be linked to this Private DNS zone with registration enabled."
}