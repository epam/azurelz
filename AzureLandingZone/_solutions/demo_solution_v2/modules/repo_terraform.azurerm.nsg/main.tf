# Get resource group data
data "azurerm_resource_group" "rg" {
  count = var.location == null ? 1 : 0
  name  = var.resource_group_name
}

# Create NSG
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location == null ? data.azurerm_resource_group.rg[0].location : var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Collect all ASG names to single array to get IDs
locals {
  inbound_destination_asg_list = [
    for rule in var.inbound_rules :
    lookup(rule, "destination_asg", [])
  ]
  outbound_destination_asg_list = [
    for rule in var.outbound_rules :
    lookup(rule, "destination_asg", [])
  ]
  inbound_source_asg_list = [
    for rule in var.inbound_rules :
    lookup(rule, "source_asg", [])
  ]
  outbound_source_asg_list = [
    for rule in var.outbound_rules :
    lookup(rule, "source_asg", [])
  ]

  asg_list = flatten(setunion(flatten(local.inbound_destination_asg_list), flatten(local.outbound_destination_asg_list), flatten(local.inbound_source_asg_list), flatten(local.outbound_source_asg_list)))

  subnet_associate = var.subnet_associate == null ? [] : var.subnet_associate
}

# Get subnet to associate with NSG
data "azurerm_subnet" "subnet_associate" {
  for_each             = { for subnet in local.subnet_associate : subnet.subnet_name => subnet }
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = lookup(each.value, "rg_name", var.resource_group_name)
}

# Associate subnet with NSG.
# NSG will be associated with subnet only after all rules are created, it significant for subnets such as AzureBastion or ApplicationGatewaySubnet.
resource "azurerm_subnet_network_security_group_association" "subnet" {
  for_each                  = { for subnet in local.subnet_associate : subnet.subnet_name => subnet }
  depends_on                = [azurerm_network_security_rule.inbound_rules, azurerm_network_security_rule.outbound_rules]
  subnet_id                 = data.azurerm_subnet.subnet_associate[each.value.subnet_name].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Get ASG data to associate with NSG
data "azurerm_application_security_group" "asg" {
  for_each            = { for asg in local.asg_list : asg.name => asg }
  name                = each.value.name
  resource_group_name = each.value.rg_name
}

# Create ASG map '<rule name> = [<asg_id_1>,<asg_id_2>...,<asg_id_n>]'
locals {
  inbound_destination_asg_ids = {
    for rule in var.inbound_rules : rule.name => [
      for asg in rule.destination_asg :
      data.azurerm_application_security_group.asg[asg.name].id
    ] if can(rule.destination_asg)
  }
  outbound_destination_asg_ids = {
    for rule in var.outbound_rules : rule.name => [
      for asg in rule.destination_asg :
      data.azurerm_application_security_group.asg[asg.name].id
    ] if can(rule.destination_asg)
  }
  inbound_source_asg_ids = {
    for rule in var.inbound_rules : rule.name => [
      for asg in rule.source_asg :
      data.azurerm_application_security_group.asg[asg.name].id
    ] if can(rule.source_asg)
  }
  outbound_source_asg_ids = {
    for rule in var.outbound_rules : rule.name => [
      for asg in rule.source_asg :
      data.azurerm_application_security_group.asg[asg.name].id
    ] if can(rule.source_asg)
  }
}

# Create NSG inbound rules
resource "azurerm_network_security_rule" "inbound_rules" {
  for_each                                   = { for rule in var.inbound_rules : rule.name => rule }
  name                                       = each.value.name
  resource_group_name                        = var.resource_group_name
  network_security_group_name                = azurerm_network_security_group.nsg.name
  priority                                   = each.value.priority
  protocol                                   = each.value.protocol
  description                                = lookup(each.value, "description", null)
  direction                                  = "Inbound"
  access                                     = lookup(each.value, "access", "Allow")
  source_port_range                          = lookup(each.value, "source_port_range", null)
  source_port_ranges                         = lookup(each.value, "source_port_ranges", null)
  destination_port_range                     = lookup(each.value, "destination_port_range", null)
  destination_port_ranges                    = lookup(each.value, "destination_port_ranges", null)
  source_address_prefix                      = lookup(each.value, "source_address_prefix", null)
  source_address_prefixes                    = lookup(each.value, "source_address_prefixes", null)
  destination_address_prefix                 = lookup(each.value, "destination_address_prefix", null)
  destination_address_prefixes               = lookup(each.value, "destination_address_prefixes", null)
  source_application_security_group_ids      = can(each.value.source_asg) ? local.inbound_source_asg_ids[each.value.name] : []
  destination_application_security_group_ids = can(each.value.destination_asg) ? local.inbound_destination_asg_ids[each.value.name] : []
}

# Create NSG outbound rules
resource "azurerm_network_security_rule" "outbound_rules" {
  for_each                                   = { for rule in var.outbound_rules : rule.name => rule }
  name                                       = each.value.name
  resource_group_name                        = var.resource_group_name
  network_security_group_name                = azurerm_network_security_group.nsg.name
  priority                                   = each.value.priority
  protocol                                   = each.value.protocol
  description                                = lookup(each.value, "description", null)
  direction                                  = "Outbound"
  access                                     = lookup(each.value, "access", "Allow")
  source_port_range                          = lookup(each.value, "source_port_range", null)
  source_port_ranges                         = lookup(each.value, "source_port_ranges", null)
  destination_port_range                     = lookup(each.value, "destination_port_range", null)
  destination_port_ranges                    = lookup(each.value, "destination_port_ranges", null)
  source_address_prefix                      = lookup(each.value, "source_address_prefix", null)
  source_address_prefixes                    = lookup(each.value, "source_address_prefixes", null)
  destination_address_prefix                 = lookup(each.value, "destination_address_prefix", null)
  destination_address_prefixes               = lookup(each.value, "destination_address_prefixes", null)
  source_application_security_group_ids      = can(each.value.source_asg) ? local.outbound_source_asg_ids[each.value.name] : []
  destination_application_security_group_ids = can(each.value.destination_asg) ? local.outbound_destination_asg_ids[each.value.name] : []
}

# NSG diagnostic setting
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_setting == null ? 0 : 1

  name                           = var.diagnostic_setting.name
  log_analytics_workspace_id     = var.diagnostic_setting.log_analytics_workspace_id
  target_resource_id             = azurerm_network_security_group.nsg.id
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
}
