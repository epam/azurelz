output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.storage.name
}

output "storage_account_rg_name" {
  description = "Resource Group Name of this Storage Account"
  value       = azurerm_storage_account.storage.resource_group_name
}

output "storage_account_id" {
  description = "Id of the storage account"
  value       = azurerm_storage_account.storage.id
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location"
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.storage.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The connection string associated with the primary location"
  value       = azurerm_storage_account.storage.primary_connection_string
  sensitive   = true
}

output "file_share_id" {
  description = "The ID of the File Share"
  value       = [for share in var.share_collection : azurerm_storage_share.storage[share.name].id if try(azurerm_storage_share.storage[share.name].id, null) != null]
}

output "file_share_url" {
  description = "The URL of the File Shar"
  value       = [for share in var.share_collection : azurerm_storage_share.storage[share.name].url if try(azurerm_storage_share.storage[share.name].url, null) != null]
}

output "container_id" {
  description = "The ID of the Storage Container"
  value       = [for container in var.container_collection : azurerm_storage_container.storage[container.name].id if try(azurerm_storage_container.storage[container.name].id, null) != null]
}
