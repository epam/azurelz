resource "azurerm_management_group" "mg" {
  name                       = var.name
  display_name               = var.display_name
  parent_management_group_id = var.parent_mg_id
}

data "azurerm_role_definition" "mg" {
  count = length(var.role_assignment_list)
  name  = var.role_assignment_list[count.index].role
}

resource "azurerm_role_assignment" "mg" {
  count              = length(var.role_assignment_list)
  scope              = azurerm_management_group.mg.id
  role_definition_id = data.azurerm_role_definition.mg[count.index].id
  principal_id       = var.role_assignment_list[count.index].object_id
  description        = var.role_assignment_list[count.index].description
}

data "azurerm_subscription" "mg" {
  count           = length(var.subscription_association_list)
  subscription_id = var.subscription_association_list[count.index]
}

resource "azurerm_management_group_subscription_association" "mg" {
  count               = length(var.subscription_association_list)
  management_group_id = azurerm_management_group.mg.id
  subscription_id     = data.azurerm_subscription.mg[count.index].id
}
 