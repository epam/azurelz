locals {
  role_definition_id = var.definition != null ? azurerm_role_definition.definition[0].role_definition_resource_id : try(var.assignment.role_definition_name, null) == null ? try(var.assignment.role_definition_id, null) : null
}

resource "azurerm_role_definition" "definition" {
  count = var.definition != null ? 1 : 0

  name               = var.definition.name
  scope              = var.definition.scope
  role_definition_id = lookup(var.definition, "role_definition_id", null)
  description        = lookup(var.definition, "description", null)

  dynamic "permissions" {
    for_each = var.definition.permissions != null ? [1] : []

    content {
      actions          = try(var.definition.permissions.actions, [])
      data_actions     = try(var.definition.permissions.data_actions, [])
      not_actions      = try(var.definition.permissions.not_actions, [])
      not_data_actions = try(var.definition.permissions.not_data_actions, [])

    }
  }

  assignable_scopes = try(var.definition.assignable_scopes, null)
}

resource "azurerm_role_assignment" "assignment" {
  count = var.assignment != null ? 1 : 0

  role_definition_id   = local.role_definition_id
  scope                = var.assignment.scope
  principal_id         = var.principal_id
  description          = lookup(var.assignment, "description", null)
  name                 = lookup(var.assignment, "name", null)
  role_definition_name = var.definition == null ? lookup(var.assignment, "role_definition_name", null) : null
  condition            = lookup(var.assignment, "condition", null)
  condition_version    = lookup(var.assignment, "condition_version", null)
}