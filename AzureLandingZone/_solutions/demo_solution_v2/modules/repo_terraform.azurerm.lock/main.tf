## Create Azurerm_management_lock

resource "azurerm_management_lock" "lock" {
  name       = var.lock_name
  scope      = var.resource_id
  lock_level = var.lock_level
  notes      = var.notes
}
