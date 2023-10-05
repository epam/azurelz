output "vm_id" {
  description = " ID of the Backup Protected Virtual Machine"
  value       = length(azurerm_backup_protected_vm.vm) != 0 ? azurerm_backup_protected_vm.vm[0].id : null
}

output "share_id" {
  description = "The ID of the Backup Azure File Share"
  value       = length(azurerm_backup_protected_file_share.share) != 0 ? azurerm_backup_protected_file_share.share[0].id : null
}

output "storage_id" {
  description = "The ID of the Storage Account"
  value       = length(azurerm_backup_container_storage_account.storage) != 0 ? azurerm_backup_container_storage_account.storage[0].storage_account_id : null
}
