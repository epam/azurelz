# 001_mg
# Deploy Managenment Groups
# The user account that is used by Terraform to manage this module should have at least 
# "Management Group Contributor" and one of "User Access Administrator" or "Owner" roles 
# on the Tenant Root Management Group level. These rights on management group needs 
# to delete management group correctly and move subscriptions into Tenant Root Management Group.
module "mg_lvl_0" {
  for_each                      = { for group in var.mg_list_lvl_0 : group.name => group }
  source                        = "../modules/repo_terraform.azurerm.mg"
  name                          = each.value.name
  display_name                  = each.value.display_name
  role_assignment_list          = lookup(each.value, "role_assignment_list", [])
  subscription_association_list = try(each.value.subscription_association_list, [])
}

module "mg_lvl_1" {
  depends_on                    = [module.mg_lvl_0]
  for_each                      = { for group in var.mg_list_lvl_1 : group.name => group }
  source                        = "../modules/repo_terraform.azurerm.mg"
  name                          = each.value.name
  display_name                  = each.value.display_name
  parent_mg_id                  = "/providers/Microsoft.Management/managementGroups/${each.value.parent_mg_name}"
  role_assignment_list          = lookup(each.value, "role_assignment_list", [])
  subscription_association_list = try(each.value.subscription_association_list, [])
}

module "mg_lvl_2" {
  depends_on                    = [module.mg_lvl_1]
  for_each                      = { for group in var.mg_list_lvl_2 : group.name => group }
  source                        = "../modules/repo_terraform.azurerm.mg"
  name                          = each.value.name
  display_name                  = each.value.display_name
  parent_mg_id                  = "/providers/Microsoft.Management/managementGroups/${each.value.parent_mg_name}"
  role_assignment_list          = lookup(each.value, "role_assignment_list", [])
  subscription_association_list = try(each.value.subscription_association_list, [])
}

module "mg_lvl_3" {
  depends_on                    = [module.mg_lvl_2]
  for_each                      = { for group in var.mg_list_lvl_3 : group.name => group }
  source                        = "../modules/repo_terraform.azurerm.mg"
  name                          = each.value.name
  display_name                  = each.value.display_name
  parent_mg_id                  = "/providers/Microsoft.Management/managementGroups/${each.value.parent_mg_name}"
  role_assignment_list          = lookup(each.value, "role_assignment_list", [])
  subscription_association_list = try(each.value.subscription_association_list, [])
}

# 004_policyinitiative
# Deploy Policy initiatives
module "policy_initiative" {
  depends_on = [
    module.mg_lvl_3
  ]
  source                 = "../modules/repo_terraform.azurerm.policy_initiative"
  for_each               = { for policy_initiative in var.policy_initiatives : policy_initiative.initiative_name => policy_initiative }
  scope                  = lookup(each.value, "scope", "subscription")
  initiative_name        = each.value.initiative_name
  description            = lookup(each.value, "description", null)
  policy_type            = lookup(each.value, "policy_type", "BuiltIn")
  display_name           = lookup(each.value, "display_name", each.value.initiative_name)
  management_group_name  = lookup(each.value, "management_group_name", null)
  policy_definition_list = lookup(each.value, "policy_definition_list", [])
  initiatives_store      = lookup(each.value, "initiatives_store", null)
  assignment_location    = lookup(each.value, "location", null)
  assignment_name        = lookup(each.value, "assignment_name", null)
  assignment_parameters  = lookup(each.value, "parameters", null)
  assignment_exemptions  = lookup(each.value, "assignment_exemptions", null)
  assignment_exclusions  = lookup(each.value, "assignment_exclusions", [])
  enforce                = lookup(each.value, "enforce", false)
  create_set_definition  = lookup(each.value, "create_set_definition", false)
  identity = lookup(each.value, "identity", { type = "SystemAssigned"
  identity_ids = null })
}

# 005_rg
# Deploy Resource Groups
module "rg" {
  source = "../modules/repo_terraform.azurerm.rg"
  depends_on = [
    module.policy_initiative
  ]
  for_each = { for rg in var.rg_list : rg.name => rg }
  name     = each.key
  location = each.value.location
  tags     = each.value.tags
}
module "rg_lock" {
  source = "../modules/repo_terraform.azurerm.lock"
  depends_on = [
    module.rg
  ]
  for_each    = { for rg in var.rg_list : rg.name => rg if try(rg.lock_name, null) != null }
  resource_id = module.rg[each.key].id
  lock_name   = each.value.lock_name
  lock_level  = each.value.lock_level
  notes       = each.value.lock_notes
}

# 006_useridentity
# Create user-assigned managed identities
module "user_identity" {
  source = "../modules/repo_terraform.azurerm.user_assigned_identity"
  depends_on = [
    module.rg
  ]
  for_each = { for id in var.user_identities : id.name => id }
  name     = each.value.name
  location = each.value.location
  rg_name  = each.value.rg_name
  tags     = lookup(each.value, "tags", {})
}

# 010_loganalytics
# Create Log Analytics with Storage Accounts and RBAC
module "storage_account_la" {
  source   = "../modules/repo_terraform.azurerm.storage_account"
  for_each = { for logAnalytic in var.logAnalytics : logAnalytic.name => logAnalytic }
  depends_on = [
    module.rg
  ]
  # storage_name                    = basename(each.value.diagnostic_setting.storage_account_id)
  storage_name                    = each.value.storage_account_name
  rg_name                         = each.value.rg_name
  allow_nested_items_to_be_public = false
  # to avoid cyclic error while creating log analytics, diagnostic_setting for storage account must be null
  # or link to existing log analytics
  diagnostic_setting = null
  tags               = lookup(each.value, "tags", {})
}
module "logAnalytics" {
  source   = "../modules/repo_terraform.azurerm.log_analytics"
  for_each = { for logAnalytic in var.logAnalytics : logAnalytic.name => logAnalytic }
  depends_on = [
    module.rg,
    module.storage_account_la
  ]
  name              = each.value.name
  rg_name           = each.value.rg_name
  pricing_tier      = each.value.pricing_tier
  retention_in_days = each.value.retention_in_days
  location          = try(each.value.location, null)
  la_solutions      = try(each.value.la_solutions, [])
  activity_log_subs = lookup(each.value, "activity_log_subs", [])
  diagnostic_setting = try(each.value.diagnostic_setting, null) != null ? {
    name               = each.value.diagnostic_setting.name
    storage_account_id = module.storage_account_la[each.value.name].storage_account_id
    log_category_group = each.value.diagnostic_setting.log_category_group
    metric             = each.value.diagnostic_setting.metric
  } : null
  tags = lookup(each.value, "tags", {})
}
module "la_rbac" {
  source = "../modules/repo_terraform.azurerm.rbac"
  depends_on = [
    module.logAnalytics
  ]
  for_each   = { for logAnalytic in var.logAnalytics : logAnalytic.name => logAnalytic if try(logAnalytic.monitoring_contributor_assigment_ids, {}) != {} }
  definition = null
  assignment = {
    scope                = module.logAnalytics[each.value.name].id
    description          = each.value.assignment_description
    role_definition_name = each.value.assignment_role_definition_name
  }
  principal_id = each.value.monitoring_contributor_assigment_ids
}

# 025_vnet
# Creating a Virtual Networks
module "vnet" {
  source = "../modules/repo_terraform.azurerm.vnet"
  depends_on = [
    module.rg,
    module.logAnalytics
  ]
  for_each                  = { for vnet in var.vnets : vnet.vnet_name => vnet }
  vnet_name                 = each.value.vnet_name
  rg_name                   = each.value.rg_name
  location                  = lookup(each.value, "location", null)
  address_space             = lookup(each.value, "address_space", ["10.0.0.0/16"])
  ddos_protection_plan_name = lookup(each.value, "ddos_protection_plan_name", null)
  dns_servers               = lookup(each.value, "dns_servers", [])
  subnets                   = lookup(each.value, "subnets", [])
  diagnostic_setting        = lookup(each.value, "diagnostic_setting", null)
  tags                      = lookup(each.value, "tags", {})
}

module "vnet_rbac" {
  source = "../modules/repo_terraform.azurerm.rbac"
  depends_on = [
    module.vnet
  ]
  for_each   = { for vnet in var.vnets : vnet.vnet_name => vnet if length(try(vnet.network_contributor_assigment_ids, [])) != 0 }
  definition = null
  assignment = {
    scope                = module.vnet[each.value.vnet_name].vnet_id
    description          = "Business LZ SPN assignment to configure peering"
    role_definition_name = "Network Contributor"
  }
  principal_id = each.value.network_contributor_assigment_ids
}
