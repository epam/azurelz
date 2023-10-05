## Get data from VNET resource group if location is not specified
data "azurerm_resource_group" "bastion_rg" {
  count = var.location == null ? 1 : 0
  name  = var.resource_group_name
}

# Get data from VNET
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_rg_name != null ? var.vnet_rg_name : var.resource_group_name
}

# Get data from AzureBastionSubnet subnet
data "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = var.vnet_name
}

# Create the Bastion host
resource "azurerm_bastion_host" "bastion" {
  name                   = var.bastion_host_name
  location               = var.location != null ? var.location : data.azurerm_resource_group.bastion_rg[0].location
  resource_group_name    = var.resource_group_name
  sku                    = var.sku
  tunneling_enabled      = var.tunneling_enabled
  shareable_link_enabled = var.shareable_link_enabled
  ip_connect_enabled     = var.ip_connect_enabled
  copy_paste_enabled     = var.copy_paste_enabled
  file_copy_enabled      = var.file_copy_enabled
  scale_units            = var.scale_units
  tags                   = var.tags

  ip_configuration {
    name                 = "${var.bastion_host_name}-ipcfg"
    subnet_id            = data.azurerm_subnet.bastion_subnet.id
    public_ip_address_id = var.public_ip_address_id
  }
}

# Create diagnostic settings for the Bastion
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_setting == null ? 0 : 1

  name                           = var.diagnostic_setting.name
  log_analytics_workspace_id     = var.diagnostic_setting.log_analytics_workspace_id
  target_resource_id             = azurerm_bastion_host.bastion.id
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
