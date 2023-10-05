#################################################################################
# Create a User-assigned managed identity 
#################################################################################

resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = var.name
  resource_group_name = var.rg_name
  location            = var.location

  tags = var.tags
}
