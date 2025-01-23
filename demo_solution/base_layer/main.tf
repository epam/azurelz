module "mg_lvl_0" {
  for_each                      = { for group in var.mg_list_lvl_0 : group.name => group }
  source                        = "../modules/repo_terraform.azurerm.mg"
  name                          = each.value.name
  display_name                  = each.value.display_name
  parent_mg_id                  = each.value.parent_mg_id
  role_assignment_list          = lookup(each.value, "role_assignment_list", [])
  subscription_association_list = each.value.subscription_association_list
}

module "mg_lvl_1" {
  depends_on                    = [module.mg_lvl_0]
  for_each                      = { for group in var.mg_list_lvl_1 : group.name => group }
  source                        = "../modules/repo_terraform.azurerm.mg"
  name                          = each.value.name
  display_name                  = each.value.display_name
  parent_mg_id                  = each.value.parent_mg_id
  role_assignment_list          = lookup(each.value, "role_assignment_list", [])
  subscription_association_list = each.value.subscription_association_list
}

module "mg_lvl_2" {
  depends_on                    = [module.mg_lvl_1]
  for_each                      = { for group in var.mg_list_lvl_2 : group.name => group }
  source                        = "../modules/repo_terraform.azurerm.mg"
  name                          = each.value.name
  display_name                  = each.value.display_name
  parent_mg_id                  = each.value.parent_mg_id
  role_assignment_list          = lookup(each.value, "role_assignment_list", [])
  subscription_association_list = each.value.subscription_association_list
}

module "mg_lvl_3" {
  depends_on                    = [module.mg_lvl_2]
  for_each                      = { for group in var.mg_list_lvl_3 : group.name => group }
  source                        = "../modules/repo_terraform.azurerm.mg"
  name                          = each.value.name
  display_name                  = each.value.display_name
  parent_mg_id                  = each.value.parent_mg_id
  role_assignment_list          = lookup(each.value, "role_assignment_list", [])
  subscription_association_list = each.value.subscription_association_list
}

### Workaround for Management group to be interactable
resource "time_sleep" "wait" {
  count = var.create_duration  != null ? 1 : 0
  depends_on = [
    module.mg_lvl_3
  ]
  create_duration = var.create_duration
}

module "policy_initiative" {
  source                 = "../modules/repo_terraform.azurerm.policy_initiative"
  depends_on             = [time_sleep.wait]
  for_each               = { for policy_initiative in var.policy_initiatives : "${policy_initiative.initiative_name}-${policy_initiative.management_group_name}" => policy_initiative }
  scope                  = each.value.scope
  initiative_name        = each.value.initiative_name
  description            = lookup(each.value, "description", null)
  policy_type            = lookup(each.value, "policy_type", "BuiltIn")
  display_name           = each.value.display_name == null ? each.value.initiative_name : each.value.display_name
  management_group_name  = lookup(each.value, "management_group_name", null)
  policy_definition_list = lookup(each.value, "policy_definition_list", [])
  initiatives_store      = lookup(each.value, "initiatives_store", null)
  assignment_location    = each.value.assignment_location
  assignment_name        = lookup(each.value, "assignment_name", null)
  assignment_parameters  = lookup(each.value, "assignment_parameters", null)
  assignment_exemptions  = lookup(each.value, "assignment_exemptions", null)
  assignment_exclusions  = lookup(each.value, "assignment_exclusions", [])
  enforce                = lookup(each.value, "enforce", false)
  create_set_definition  = lookup(each.value, "create_set_definition", false)
  identity               = each.value.identity
}

module "rg" {
  source     = "../modules/repo_terraform.azurerm.rg"
  depends_on = [module.policy_initiative]
  for_each   = { for rg in var.rg_list : rg.name => rg }
  name       = each.key
  location   = each.value.location
  tags       = each.value.tags
}

module "user_assigned_identity" {
  source     = "../modules/repo_terraform.azurerm.user_assigned_identity"
  depends_on = [module.rg]
  for_each   = { for identity in var.identity : identity.identity_name => identity }
  name       = each.value.identity_name
  rg_name    = each.value.rg_name
  location   = each.value.location
  tags       = each.value.tags
}

module "storage_account" {
  source                            = "../modules/repo_terraform.azurerm.storage_account"
  for_each                          = { for storage_account in var.storage_accounts : storage_account.storage_name => storage_account }
  depends_on                        = [module.rg]
  storage_name                      = lower(each.value.storage_name)
  location                          = each.value.location
  rg_name                           = each.value.rg_name
  allow_nested_items_to_be_public   = each.value.allow_nested_items_to_be_public
  account_replication_type          = each.value.account_replication_type
  public_network_access_enabled     = each.value.public_network_access_enabled
  shared_access_key_enabled         = each.value.shared_access_key_enabled
  infrastructure_encryption_enabled = each.value.infrastructure_encryption_enabled
  identity                          = each.value.identity
  network_rules                     = each.value.network_rules
  customer_managed_key              = each.value.customer_managed_key
  azure_files_authentication        = each.value.azure_files_authentication
  sas_policy                        = each.value.sas_policy
  versioning_enabled                = each.value.versioning_enabled
  large_file_share_enabled          = each.value.large_file_share_enabled
  account_kind                      = each.value.account_kind
  account_tier                      = each.value.account_tier
  enable_https_traffic_only         = each.value.enable_https_traffic_only
  min_tls_version                   = each.value.min_tls_version
  change_feed_enabled               = each.value.change_feed_enabled
  logging                           = each.value.logging
  is_hns_enabled                    = each.value.is_hns_enabled
  container_collection              = each.value.container_collection
  share_collection                  = each.value.share_collection
  blob_delete_retention_day         = each.value.blob_delete_retention_day
  access_tier                       = each.value.access_tier
  change_feed_retention_in_days     = each.value.change_feed_retention_in_days
  diagnostic_setting                = lookup(each.value, "diagnostic_setting", {})
  tags                              = lookup(each.value, "tags", {})
}

module "logAnalytics" {
  source             = "../modules/repo_terraform.azurerm.log_analytics"
  depends_on         = [module.storage_account]
  for_each           = { for logAnalytic in var.logAnalytics : logAnalytic.name => logAnalytic }
  name               = each.value.name
  rg_name            = each.value.rg_name
  daily_quota_gb     = each.value.daily_quota_gb
  deployment_mode    = each.value.deployment_mode
  pricing_tier       = each.value.pricing_tier
  retention_in_days  = each.value.retention_in_days
  location           = each.value.location
  la_solutions       = each.value.la_solutions
  activity_log_subs  = lookup(each.value, "activity_log_subs", [])
  diagnostic_setting = each.value.diagnostic_setting
  tags               = lookup(each.value, "tags", {})
}

module "vnet" {
  source                    = "../modules/repo_terraform.azurerm.vnet"
  for_each                  = { for vnet in var.vnets : vnet.vnet_name => vnet }
  depends_on                = [module.logAnalytics]
  vnet_name                 = each.value.vnet_name
  rg_name                   = each.value.rg_name
  location                  = each.value.location
  address_space             = lookup(each.value, "address_space", ["10.0.0.0/16"])
  ddos_protection_plan_name = lookup(each.value, "ddos_protection_plan_name", null)
  dns_servers               = lookup(each.value, "dns_servers", [])
  subnets                   = lookup(each.value, "subnets", [])
  diagnostic_setting        = each.value.diagnostic_setting
  tags                      = lookup(each.value, "tags", {})
}

locals {
  rbac = flatten([
    for entry in var.rbac : [
      for principal_id in entry.principal_ids : {
        definition = entry.definition
        assignment = {
          name                 = entry.assignment.name
          scope                = try(entry.assignment.scope, null)
          description          = try(entry.assignment.description, null)
          role_definition_name = try(entry.assignment.role_definition_name, null)
          condition            = try(entry.assignment.condition, null)
          condition_version    = try(entry.assignment.condition_version, null)
        }
        principal_id = principal_id
      }
    ]
  ])
}

module "rbac" {
  source       = "../modules/repo_terraform.azurerm.rbac"
  for_each     = { for role in local.rbac : "${role.assignment.description}-${role.principal_id}" => role }
  depends_on   = [module.logAnalytics]
  definition   = lookup(each.value, "definition", null)
  assignment   = lookup(each.value, "assignment", null)
  principal_id = lookup(each.value, "principal_id", null)
}

module "lock" {
  source   = "../modules/repo_terraform.azurerm.lock"
  for_each = { for lock in var.locks : lock.lock_name => lock }
  depends_on = [
    module.user_assigned_identity,
    module.vnet,
    module.rbac
  ]
  resource_id = each.value.resource_id
  lock_name   = each.value.lock_name
  lock_level  = each.value.lock_level
  notes       = lookup(each.value, "notes", null)
}