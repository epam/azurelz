output "policy_set_definition_id" {
  description = "The ID of the Policy Set Definition"
  value       = toset(try([for policy_initiative in var.policy_initiatives : module.policy_initiative[policy_initiative.initiative_name].policy_set_definition_id], null))
}

output "policy_set_definition_assignment_id" {
  description = "The Policy Set Definition Assignment Id"
  value       = toset(try([for policy_initiative in var.policy_initiatives : module.policy_initiative[policy_initiative.initiative_name].policy_set_definition_assignment_id], null))
}

output "policy_set_assignment_identity_id" {
  description = "The Managed Identity block containing Principal Id & Tenant Id of this Policy Set Definition Assignment"
  value       = toset(try([for policy_initiative in var.policy_initiatives : module.policy_initiative[policy_initiative.initiative_name].policy_set_assignment_identity_id], null))
}

output "subscription_policy_assignment_id" {
  description = "The Policy Assignment Id"
  value       = toset(try([for policy_initiative in var.policy_initiatives : module.policy_initiative[policy_initiative.initiative_name].subscription_policy_assignment_id], null))
}

output "subscription_policy_identity_id" {
  description = "The Managed Identity block containing Principal Id & Tenant Id of this Policy Assignment"
  value       = toset(try([for policy_initiative in var.policy_initiatives : module.policy_initiative[policy_initiative.initiative_name].subscription_policy_identity_id], null))
}

output "rg_id" {
  value       = { for rg in var.rg_list : rg.name => module.rg[rg.name].id }
  description = "The ID of created resource group for additional resources"
}

output "rg_location" {
  value       = { for rg in var.rg_list : rg.name => module.rg[rg.name].location }
  description = "Name of resource group for additional resources"
}

output "user_assigned_identity_ids" {
  description = "IDs of the User Assigned Identities"
  value       = { for identity in var.identity : identity.identity_name => module.user_assigned_identity[identity.identity_name].id }
}
output "principal_id" {
  description = "Service Principal ID associated with the user assigned identity"
  value       = { for identity in var.identity : identity.identity_name => module.user_assigned_identity[identity.identity_name].principal_id }
}

output "client_id" {
  description = "Client ID associated with the user assigned identity"
  value       = { for identity in var.identity : identity.identity_name => module.user_assigned_identity[identity.identity_name].client_id }
}

output "tenant_id" {
  description = "Tenant ID associated with the user assigned identity"
  value       = { for identity in var.identity : identity.identity_name => module.user_assigned_identity[identity.identity_name].tenant_id }
}

output "identities" {
  value = merge({
    for identity in var.identity : identity.identity_name => {
      id           = module.user_assigned_identity[identity.identity_name].id
      principal_id = module.user_assigned_identity[identity.identity_name].principal_id
      client_id    = module.user_assigned_identity[identity.identity_name].client_id
      tenant_id    = module.user_assigned_identity[identity.identity_name].tenant_id
    }
  })
  description = "The user assigned identities."
}

output "log_analytics_workspace_id" {
  value       = { for logAnalytic in var.logAnalytics : logAnalytic.name => module.logAnalytics[logAnalytic.name].log_analytics_workspace_id }
  description = "The ID created of the log analytics workspace"
}

output "log_analytics_workspace_name" {
  value       = [for logAnalytic in var.logAnalytics : module.logAnalytics[logAnalytic.name].log_analytics_workspace_name]
  description = "The name of the created log analytics workspace"
}

output "storage_account_id" {
  value       = { for storage_account in var.storage_accounts : storage_account.storage_name => module.storage_account[storage_account.storage_name].storage_account_id }
  description = "The ID of the created storage account"
}

output "vnets" {
  value = [
    for vnet in var.vnets : {
      vnet_ids            = module.vnet[vnet.vnet_name].vnet_id
      vnet_names          = module.vnet[vnet.vnet_name].vnet_name
      vnet_address_spaces = module.vnet[vnet.vnet_name].vnet_address_space
      vnet_config         = vnet.address_space
      vnet_subnets        = module.vnet[vnet.vnet_name].vnet_subnet_ids
    }
  ]
  description = "The Virtual networks."
}

output "lock_id" {
  description = "The ID of the Management Lock"
  value       = [for lock in var.locks : module.lock[lock.lock_name].lock_id]
}
