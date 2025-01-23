# Get resource group data
data "azurerm_resource_group" "storage" {
  name = var.rg_name
}

# Retrieving subnet data
data "azurerm_subnet" "storage" {
  count                = var.network_rules == null ? 0 : length(var.network_rules.subnet_associations)
  name                 = var.network_rules.subnet_associations[count.index].subnet_name
  virtual_network_name = var.network_rules.subnet_associations[count.index].vnet_name
  resource_group_name  = var.network_rules.subnet_associations[count.index].rg_name
}

# Create storage account
#tfsec:ignore:azure-storage-queue-services-logging-enabled tfsec:ignore:azure-storage-default-action-deny
resource "azurerm_storage_account" "storage" {
  name                              = var.storage_name
  resource_group_name               = data.azurerm_resource_group.storage.name
  location                          = var.location != null ? var.location : data.azurerm_resource_group.storage.location
  account_tier                      = var.account_tier
  account_kind                      = var.account_kind
  account_replication_type          = var.account_replication_type
  min_tls_version                   = var.min_tls_version
  access_tier                       = var.access_tier
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  large_file_share_enabled          = var.large_file_share_enabled
  enable_https_traffic_only         = var.enable_https_traffic_only
  is_hns_enabled                    = var.is_hns_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  tags                              = var.tags

  queue_properties {
    dynamic "logging" {
      for_each = var.logging != null ? [var.logging] : []
      content {
        delete                = var.logging.delete
        write                 = var.logging.write
        read                  = var.logging.read
        version               = var.logging.version
        retention_policy_days = var.logging.retention_policy_days
      }
    }
  }
  blob_properties {
    delete_retention_policy {
      days = var.blob_delete_retention_day
    }
    versioning_enabled            = var.versioning_enabled
    change_feed_retention_in_days = var.change_feed_retention_in_days
    change_feed_enabled           = var.change_feed_enabled
  }

  ####  Disabled the TFSec "AZ013" check to avoid the warning "Resource 'azurerm_storage_account.storage' defines a network rule that doesn't allow bypass of Microsoft Services"
  # Creating network access control rules for storage account
  network_rules {
    bypass                     = [try(var.network_rules.bypass, "AzureServices")]
    default_action             = try(var.network_rules.default_action, "Deny")
    ip_rules                   = try(var.network_rules.ip_rules, [])
    virtual_network_subnet_ids = concat(flatten(data.azurerm_subnet.storage[*].id), try(var.network_rules.external_subnet_ids, []))
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = var.identity.type
      identity_ids = var.identity.identity_ids
    }
  }

  dynamic "sas_policy" {
    for_each = var.sas_policy != null ? [var.sas_policy] : []
    content {
      expiration_period = var.sas_policy.expiration_period
      expiration_action = var.sas_policy.expiration_action
    }
  }

  dynamic "azure_files_authentication" {
    for_each = var.azure_files_authentication != {} ? [1] : []
    content {
      directory_type = var.azure_files_authentication.directory_type

      dynamic "active_directory" {
        for_each = var.azure_files_authentication.directory_type == "AD" ? [1] : []
        content {
          storage_sid         = var.azure_files_authentication.active_directory.storage_sid
          domain_guid         = var.azure_files_authentication.active_directory.domain_guid
          domain_name         = var.azure_files_authentication.active_directory.domain_name
          domain_sid          = var.azure_files_authentication.active_directory.domain_sid
          forest_name         = var.azure_files_authentication.active_directory.forest_name
          netbios_domain_name = var.azure_files_authentication.active_directory.netbios_domain_name
        }
      }
    }
  }
}

# Creatue customer managed key
resource "azurerm_storage_account_customer_managed_key" "this" {
  count                        = var.customer_managed_key == null ? 0 : 1
  storage_account_id           = azurerm_storage_account.storage.id
  key_name                     = var.customer_managed_key.key_name
  key_vault_id                 = var.customer_managed_key.key_vault_id
  key_vault_uri                = var.customer_managed_key.key_vault_uri
  key_version                  = var.customer_managed_key.key_version
  user_assigned_identity_id    = var.customer_managed_key.user_assigned_identity_id
  federated_identity_client_id = var.customer_managed_key.federated_identity_client_id
}

# Create storage share
resource "azurerm_storage_share" "storage" {
  for_each             = { for share in var.share_collection : share.name => share }
  name                 = lower(each.value.name)
  storage_account_name = azurerm_storage_account.storage.name
  quota                = each.value.quota
  enabled_protocol     = lookup(each.value, "enabled_protocol", "SMB")
  access_tier          = lookup(each.value, "access_tier", "Hot")
}

# Create storage container
resource "azurerm_storage_container" "storage" {
  for_each              = { for container in var.container_collection : container.name => container }
  name                  = lower(each.value.name)
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = lookup(each.value, "container_access_type", "private")
}

# Manages a diagnostic setting for created storage account
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_setting == null ? 0 : 1

  name                           = var.diagnostic_setting.name
  log_analytics_workspace_id     = var.diagnostic_setting.log_analytics_workspace_id
  target_resource_id             = azurerm_storage_account.storage.id
  storage_account_id             = var.diagnostic_setting.storage_account_id
  eventhub_name                  = var.diagnostic_setting.eventhub_name
  eventhub_authorization_rule_id = var.diagnostic_setting.eventhub_authorization_rule_id

  dynamic "metric" {
    for_each = var.diagnostic_setting.metric != null ? toset(var.diagnostic_setting.metric) : []
    content {
      category = metric.key
    }
  }
}
