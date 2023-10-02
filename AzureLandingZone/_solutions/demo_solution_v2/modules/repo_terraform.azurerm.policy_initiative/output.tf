output "policy_set_definition_id" {
  description = "The ID of the Policy Set Definition"
  value       = try(azurerm_policy_set_definition.policy_set[0].id, null)
}

output "policy_set_definition_assignment_id" {
  description = "The Policy Set Definition Assignment Id"
  value       = try(azurerm_management_group_policy_assignment.policy_assignment[0].id, null)
}

output "policy_set_assignment_identity_id" {
  description = "The Managed Identity block containing Principal Id & Tenant Id of this Policy Set Definition Assignment"
  value       = try(azurerm_management_group_policy_assignment.policy_assignment[0].identity[0].principal_id, null)
}

output "subscription_policy_assignment_id" {
  description = "The Policy Assignment Id"
  value       = try(azurerm_subscription_policy_assignment.policy_assignment[0].id, null)
}

output "subscription_policy_identity_id" {
  description = "The Managed Identity block containing Principal Id & Tenant Id of this Policy Assignment"
  value       = try(azurerm_subscription_policy_assignment.policy_assignment[0].identity[0].principal_id, null)
}
