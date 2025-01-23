# Get resource group data
data "azurerm_resource_group" "rg" {
  count = var.location == null ? 1 : 0
  name  = var.resource_group_name
}

# Get firewall policy
data "azurerm_firewall_policy" "policy" {
  count               = var.firewall_policy_name != null ? 1 : 0
  name                = var.firewall_policy_name
  resource_group_name = var.firewall_policy_rg_name
}

# Create Azure firewall
resource "azurerm_firewall" "firewall" {
  name                = var.name
  location            = var.location == null ? data.azurerm_resource_group.rg[0].location : var.location
  resource_group_name = var.resource_group_name
  sku_tier            = var.sku_tier
  sku_name            = var.sku_name
  zones               = var.zones == null ? null : var.zones
  dns_servers         = var.dns_servers
  dns_proxy_enabled   = var.dns_proxy_enabled
  firewall_policy_id  = var.firewall_policy_name != null ? data.azurerm_firewall_policy.policy[0].id : null
  tags                = var.tags

  ip_configuration {
    name                 = "ip_configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = var.public_ip_address_id
  }

  dynamic "management_ip_configuration" {
    for_each = var.management_ip_configuration
    content {
      name                 = management_ip_configuration.value.name
      subnet_id            = management_ip_configuration.value.subnet_id
      public_ip_address_id = management_ip_configuration.value.public_ip_address_id
    }
  }
}

# Create Azure firewall network rule collections
resource "azurerm_firewall_network_rule_collection" "netw_rule_collection" {
  for_each = { for net_rule in var.netw_rule_collections : net_rule.name => net_rule }

  name                = each.value.name
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_firewall.firewall.resource_group_name
  priority            = each.value.priority
  action              = each.value.action

  dynamic "rule" {
    for_each = { for rules in lookup(each.value, "rule", []) : rules.name => rules }
    content {
      name                  = lookup(rule.value, "name")
      description           = lookup(rule.value, "description", null)
      source_addresses      = lookup(rule.value, "source_addresses", null)
      source_ip_groups      = lookup(rule.value, "source_ip_groups", null)
      destination_addresses = lookup(rule.value, "destination_addresses", null)
      destination_ip_groups = lookup(rule.value, "destination_ip_groups", null)
      destination_fqdns     = lookup(rule.value, "destination_fqdns", null)
      destination_ports     = lookup(rule.value, "destination_ports")
      protocols             = lookup(rule.value, "protocols")
    }
  }
}

# Manages a diagnostic setting for Azure firewall
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_setting == null ? 0 : 1

  name                           = var.diagnostic_setting.name
  log_analytics_workspace_id     = var.diagnostic_setting.log_analytics_workspace_id
  target_resource_id             = azurerm_firewall.firewall.id
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
