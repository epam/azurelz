#Retrieving group data from AAD
data "azuread_group" "main" {
  count        = length(local.group_names)
  display_name = local.group_names[count.index]
}

# Retrieving user data from AAD
data "azuread_user" "main" {
  count               = length(local.user_principal_names)
  user_principal_name = local.user_principal_names[count.index]
}

# Retrieving service_principal data from AAD
data "azuread_service_principal" "main" {
  count        = length(local.application_names)
  display_name = local.application_names[count.index]
}

# Retrieving resuorce group data
data "azurerm_resource_group" "main" {
  count = var.location == null ? 1 : 0
  name  = var.resource_group_name
}

# Retrieving client config data on runtime
data "azurerm_client_config" "main" {}

# Retrieving subnet data
data "azurerm_subnet" "main" {
  count                = var.network_acls == null ? 0 : length(try(var.network_acls.subnet_associations, []))
  name                 = var.network_acls.subnet_associations[count.index].subnet_name
  virtual_network_name = var.network_acls.subnet_associations[count.index].vnet_name
  resource_group_name  = var.network_acls.subnet_associations[count.index].rg_name
}

# Creating key vault
#tfsec:ignore:no-purge tfsec:ignore:specify-network-acl
resource "azurerm_key_vault" "main" {
  name                            = var.name
  location                        = var.location != null ? var.location : data.azurerm_resource_group.main[0].location
  resource_group_name             = var.resource_group_name
  tenant_id                       = data.azurerm_client_config.main.tenant_id
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  sku_name                        = var.sku
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days

  # Creating access policies to key vault resources for each user, group, application
  dynamic "access_policy" {
    for_each = var.enable_rbac_authorization ? [] : local.combined_access_policies

    content {
      tenant_id               = data.azurerm_client_config.main.tenant_id
      object_id               = access_policy.value.object_id
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }

  # Creating network access control rules for key vault
  network_acls {
    bypass                     = try(var.network_acls.bypass, "AzureServices")
    default_action             = try(var.network_acls.default_action, "Allow")
    ip_rules                   = try(var.network_acls.ip_rules, [])
    virtual_network_subnet_ids = flatten(data.azurerm_subnet.main[*].id)
  }
  tags = var.tags
}

# Manages a diagnostic setting for created key vault
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_setting == null ? 0 : 1

  name                           = var.diagnostic_setting.name
  log_analytics_workspace_id     = var.diagnostic_setting.log_analytics_workspace_id
  target_resource_id             = azurerm_key_vault.main.id
  storage_account_id             = var.diagnostic_setting.storage_account_id
  eventhub_name                  = var.diagnostic_setting.eventhub_name
  eventhub_authorization_rule_id = var.diagnostic_setting.eventhub_authorization_rule_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_setting.log_category != null ? toset(var.diagnostic_setting.log_category) : []
    content {
      category = enabled_log.key
    }
  }

  dynamic "enabled_log" {
    for_each = var.diagnostic_setting.log_category_group != null ? toset(var.diagnostic_setting.log_category_group) : []
    content {
      category_group = enabled_log.key
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_setting.metric != null ? toset(var.diagnostic_setting.metric) : []
    content {
      category = metric.key
    }
  }
}
