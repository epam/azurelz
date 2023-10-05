# 001_mg (none)

# 004_policyinitiative
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

# 005_rg
output "rg_id" {
  value = [for rg in var.rg_list : module.rg[rg.name].id]
}
output "rg_location" {
  value = [for rg in var.rg_list : module.rg[rg.name].location]
}

# 006_useridentity
output "identities" {
  value = merge({
    for id in var.user_identities : id.name => {
      id           = module.user_identity[id.name].id
      principal_id = module.user_identity[id.name].principal_id
      client_id    = module.user_identity[id.name].client_id
      tenant_id    = module.user_identity[id.name].tenant_id
    }
  })
  description = "The user assigned identities."
}

# 010_loganalytics
output "log_analytics_workspace_id" {
  value       = { for logAnalytic in var.logAnalytics : logAnalytic.name => module.logAnalytics[logAnalytic.name].log_analytics_workspace_id }
  description = "The ID created log analytics workspace"
}
output "log_analytics_id" {
  value       = { for logAnalytic in var.logAnalytics : logAnalytic.name => module.logAnalytics[logAnalytic.name].id }
  description = "The ID of the created log analytics"
}
output "log_analytics_workspace_name" {
  value       = { for logAnalytic in var.logAnalytics : logAnalytic.name => module.logAnalytics[logAnalytic.name].log_analytics_workspace_name }
  description = "The name of the created log analytics workspace"
}

# 025_vnet
output "vnets" {
  value = [
    for vnet in var.vnets : {
      vnet_ids            = module.vnet[vnet.vnet_name].vnet_id
      vnet_names          = module.vnet[vnet.vnet_name].vnet_name
      vnet_address_spaces = module.vnet[vnet.vnet_name].vnet_address_space
      vnet_config         = vnet.address_space
      vnet_subnets        = module.vnet[vnet.vnet_name].vnet_subnets
    }
  ]
  description = "The Virtual networks."
}
