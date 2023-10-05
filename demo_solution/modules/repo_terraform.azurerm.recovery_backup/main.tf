#############################################################################################
# Create Azure Backup for an Azure VM
#############################################################################################

resource "azurerm_backup_protected_vm" "vm" {
  count               = var.type == "vm" ? 1 : 0
  resource_group_name = var.vault_rg
  recovery_vault_name = var.vault_name
  source_vm_id        = var.backup_resource_id
  backup_policy_id    = var.policy_id
}


#############################################################################################
# Register Storage Account within Recovery Vault
#############################################################################################

resource "azurerm_backup_container_storage_account" "storage" {
  count               = var.type == "storage" ? 1 : 0
  resource_group_name = var.vault_rg
  recovery_vault_name = var.vault_name
  storage_account_id  = var.backup_resource_id
}


#############################################################################################
# Create Azure Backup for an Azure Share
#############################################################################################

resource "azurerm_backup_protected_file_share" "share" {
  count                     = var.type == "share" ? 1 : 0
  resource_group_name       = var.vault_rg
  recovery_vault_name       = var.vault_name
  source_storage_account_id = var.backup_resource_id
  source_file_share_name    = var.share
  backup_policy_id          = var.policy_id
}
