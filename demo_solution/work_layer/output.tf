output "aa_automation_account_id" {
  description = "The ID of the Automation Account."
  value       = [for automation_account in var.automation_accounts : module.automation_account[automation_account.automation_account_name].automation_account_id]
}

output "aa_managed_identity_id" {
  description = "The ID of the Managed Identity"
  value       = flatten([for automation_account in var.automation_accounts : module.automation_account[automation_account.automation_account_name].managed_identity_id])
}

output "aa_webhook_id" {
  description = "The Automation Webhook ID"
  value       = flatten([for automation_account in var.automation_accounts : module.automation_account[automation_account.automation_account_name].webhook_id])
}

output "aa_module_id" {
  description = "The Automation Module ID"
  value       = flatten([for automation_account in var.automation_accounts : module.automation_account[automation_account.automation_account_name].module_id])
}

output "aa_schedule_id" {
  description = "The Automation Schedule ID"
  value       = flatten([for automation_account in var.automation_accounts : module.automation_account[automation_account.automation_account_name].schedule_id])
}

output "aa_runbook_id" {
  description = "The Automation Runbook ID"
  value       = flatten([for automation_account in var.automation_accounts : module.automation_account[automation_account.automation_account_name].runbook_id])
}

output "public_ip_ids" {
  description = "The ID of this Public IP."
  value       = { for public_ip in var.public_ips : public_ip.name => module.public_ip[public_ip.name].id }
}

output "public_ip_names" {
  description = "The name of the Public IP resource"
  value       = { for public_ip in var.public_ips : public_ip.name => module.public_ip[public_ip.name].name }
}

output "public_ip_addresses" {
  description = "The IP address value that was allocated."
  value       = { for public_ip in var.public_ips : public_ip.name => module.public_ip[public_ip.name].ip_address }
}

output "public_ip_fqdns" {
  description = "Fully qualified domain name of the A DNS record associated with the public IP."
  value       = { for public_ip in var.public_ips : public_ip.name => module.public_ip[public_ip.name].fqdn }
}

output "public_ip_names_ids_map" {
  description = "The ID's of the Public IP resource map"
  value       = zipmap([for public_ip in var.public_ips : module.public_ip[public_ip.name].name], [for public_ip in var.public_ips : module.public_ip[public_ip.name].id])
}

output "public_ip_names_addresses_map" {
  description = "The IP address's  that was allocated map."
  value       = zipmap([for public_ip in var.public_ips : module.public_ip[public_ip.name].name], [for public_ip in var.public_ips : module.public_ip[public_ip.name].ip_address])
}

output "nsg_list" {
  description = "List of Network Security Groups with their names and IDs."
  value = [for nsg in var.nsg_list : {
    name   = module.nsg[nsg.nsg_name].nsg_name
    nsg_id = module.nsg[nsg.nsg_name].nsg_id
  }]
}

output "vgw_id" {
  description = "The ID of the Local Network Gateway"
  value       = [for virtual_gateway in var.virtual_gateways : module.virtual_gateway[virtual_gateway.name].id]
}

output "vgw_name" {
  description = "The ID of the Local Network Gateway"
  value       = [for virtual_gateway in var.virtual_gateways : module.virtual_gateway[virtual_gateway.name].name]
}

output "vgw_bgp_peering_address" {
  description = "The Ip address for bgp peering"
  value       = try([for virtual_gateway in var.virtual_gateways : module.virtual_gateway[virtual_gateway.name].bgp_peering_address], null)
}

output "pdns_id" {
  value       = [for dns_zone in var.private_dns_zones : module.private_dns[dns_zone.private_dns_zone_name].id]
  description = "The ID of the Private DNS Zone"
}

output "pdns_soa_record" {
  value       = [for dns_zone in var.private_dns_zones : module.private_dns[dns_zone.private_dns_zone_name].soa_record]
  description = "An SOA record block for the Private DNS Zone"
}

output "pdns_number_of_record_sets" {
  value       = [for dns_zone in var.private_dns_zones : module.private_dns[dns_zone.private_dns_zone_name].number_of_record_sets]
  description = "The current number of record sets in each Private DNS zone"
}

output "pdns_max_number_of_record_sets" {
  value       = [for dns_zone in var.private_dns_zones : module.private_dns[dns_zone.private_dns_zone_name].max_number_of_record_sets]
  description = "The maximum number of record sets that can be created in each Private DNS zone"
}

output "pdns_max_number_of_virtual_network_links" {
  value       = [for dns_zone in var.private_dns_zones : module.private_dns[dns_zone.private_dns_zone_name].max_number_of_virtual_network_links]
  description = "The maximum number of virtual networks that can be linked to each Private DNS zone"
}

output "pdns_max_number_of_virtual_network_links_with_registration" {
  value       = [for dns_zone in var.private_dns_zones : module.private_dns[dns_zone.private_dns_zone_name].max_number_of_virtual_network_links_with_registration]
  description = "The maximum number of virtual networks that can be linked to each Private DNS zone with registration enabled"
}

output "kv_id" {
  value       = [for keyvault in var.keyvaults : module.keyvault[keyvault.name].id]
  description = "The ID of the Key Vault."
}

output "kv_name" {
  value       = [for keyvault in var.keyvaults : module.keyvault[keyvault.name].name]
  description = "The name of the Key Vault."
}

output "kv_uri" {
  value       = [for keyvault in var.keyvaults : module.keyvault[keyvault.name].uri]
  description = "The URI of the Key Vault."
}

output "secrets_ids" {
  value       = [for keyvaultcontent in var.keyvaultcontents : module.keyvaultcontent[keyvaultcontent.keyvault_id].secrets_id]
  description = "The Key Vault Secret ID."
}

output "secrets_resource_ids" {
  value       = [for keyvaultcontent in var.keyvaultcontents : module.keyvaultcontent[keyvaultcontent.keyvault_id].secrets_resource_id]
  description = <<EOF
    The (Versioned) ID for this Key Vault Secret. This property points to a specific version of a Key Vault Secret, 
    as such using this won't auto-rotate values if used in other Azure Services.
  EOF
}

output "keys_ids" {
  value       = [for keyvaultcontent in var.keyvaultcontents : module.keyvaultcontent[keyvaultcontent.keyvault_id].keys_id]
  description = "The Key Vault Key ID."
}

output "keys_resource_ids" {
  value       = [for keyvaultcontent in var.keyvaultcontents : module.keyvaultcontent[keyvaultcontent.keyvault_id].keys_resource_id]
  description = <<EOF
    The (Versioned) ID for this Key Vault Key. This property points to a specific version of a Key Vault Key,
    as such using this won't auto-rotate values if used in other Azure Services.
  EOF
}

output "certificates_ids" {
  value       = [for keyvaultcontent in var.keyvaultcontents : module.keyvaultcontent[keyvaultcontent.keyvault_id].certificates_id]
  description = "The Key Vault Certificate ID."
}

output "certificates_versions" {
  value       = [for keyvaultcontent in var.keyvaultcontents : module.keyvaultcontent[keyvaultcontent.keyvault_id].certificates_version]
  description = "The current version of the Key Vault Certificate."
}

output "certificates_thumbprints" {
  value       = [for keyvaultcontent in var.keyvaultcontents : module.keyvaultcontent[keyvaultcontent.keyvault_id].certificates_thumbprint]
  description = "The X509 Thumbprint of the Key Vault Certificate represented as a hexadecimal string."
}

output "storage_account_name" {
  value = { for storage_account in var.storage_accounts : storage_account.storage_name => module.storage_account[storage_account.storage_name].storage_account_name }
}
output "storage_account_id" {
  value = { for storage_account in var.storage_accounts : storage_account.storage_name => module.storage_account[storage_account.storage_name].storage_account_id }
}
output "storage_account_primary_blob_endpoint" {
  value = { for storage_account in var.storage_accounts : storage_account.storage_name => module.storage_account[storage_account.storage_name].primary_blob_endpoint }
}
output "storage_account_primary_access_key" {
  value     = { for storage_account in var.storage_accounts : storage_account.storage_name => module.storage_account[storage_account.storage_name].primary_access_key }
  sensitive = true
}
output "storage_account_primary_connection_string" {
  value     = { for storage_account in var.storage_accounts : storage_account.storage_name => module.storage_account[storage_account.storage_name].primary_connection_string }
  sensitive = true
}
output "storage_account_file_share_id" {
  value = { for storage_account in var.storage_accounts : storage_account.storage_name => module.storage_account[storage_account.storage_name].file_share_id if can(module.storage_account[storage_account.storage_name].file_share_id) }
}

output "storage_account_file_share_url" {
  value = { for storage_account in var.storage_accounts : storage_account.storage_name => module.storage_account[storage_account.storage_name].file_share_url if can(module.storage_account[storage_account.storage_name].file_share_url) }
}

output "storage_account_container_id" {
  value = { for storage_account in var.storage_accounts : storage_account.storage_name => module.storage_account[storage_account.storage_name].container_id if can(module.storage_account[storage_account.storage_name].container_id) }
}

output "azure_firewall_ip_configuration_private_ip_addresses" {
  description = "The Private IP address of the Azure Firewall."
  value       = [for azure_firewall in module.azure_firewall : module.azure_firewall[azure_firewall.name].ip_configuration_private_ip_address]
}

output "azure_firewall_names" {
  description = "Azure firewall names"
  value       = [for azure_firewall in module.azure_firewall : module.azure_firewall[azure_firewall.name].name]
}

output "bastion_host_id" {
  description = "The ID of the Bastion Host"
  value       = [for bastion_host in var.bastion_host : module.bastion_host[bastion_host.bastion_host_name].id]
}

output "udr_id" {
  description = "The Route Table ID"
  value       = [for route_table in var.route_tables : module.udr[route_table.name].id]
}

output "udr_name" {
  description = "The Route Table name"
  value       = [for route_table in var.route_tables : module.udr[route_table.name].name]
}

output "appgtw_id" {
  description = "The ID of the Application Gateway"
  value       = [for app_gateway in var.app_gateways : module.app_gateway[app_gateway.name].id]
}

output "vm_id" {
  description = "The ID of the virtual machine"
  value       = try([for vm in var.vms : module.vm[vm.vm_name].vm_id], null)
}

output "vm_private_ip_addresses" {
  description = "The private IP addresses of the virtual machine"
  value       = try([for vm in var.vms : module.vm[vm.vm_name].private_ip_addresses], null)
}

output "vm_identity" {
  description = "The ID of the identity assigned to the VM"
  value       = try([for vm in var.vms : module.vm[vm.vm_name].vm_identity], null)
}