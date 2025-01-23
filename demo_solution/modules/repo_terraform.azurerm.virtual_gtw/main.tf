# Get resource group data
data "azurerm_resource_group" "rg" {
  count = var.location == null ? 1 : 0
  name  = var.resource_group_name
}

# Create Azure virtual network gateway
resource "azurerm_virtual_network_gateway" "virtual_gateway" {
  timeouts {
    create = "60m"
    delete = "60m"
    update = "60m"
  }
  name                = var.name
  location            = var.location == null ? data.azurerm_resource_group.rg[0].location : var.location
  resource_group_name = var.resource_group_name
  type                = var.type
  vpn_type            = var.vpn_type
  active_active       = var.active_active
  enable_bgp          = var.enable_bgp
  sku                 = var.sku
  generation          = var.generation
  tags                = var.tags

  dynamic "ip_configuration" {
    for_each = toset(var.ip_configuration)
    iterator = ip_cfg
    content {
      name                          = ip_cfg.value.name
      public_ip_address_id          = ip_cfg.value.public_ip_address_id
      private_ip_address_allocation = ip_cfg.value.private_ip_address_allocation
      subnet_id                     = ip_cfg.value.subnet_id
    }
  }
}

resource "azurerm_virtual_network_gateway_connection" "connection" {
  count               = var.connection != null ? 1 : 0
  name                = lookup(var.connection, "name", "Null")
  location            = var.location == null ? data.azurerm_resource_group.rg[0].location : var.location
  resource_group_name = var.resource_group_name

  virtual_network_gateway_id = azurerm_virtual_network_gateway.virtual_gateway.id

  express_route_circuit_id        = lookup(var.connection, "express_route_circuit_id", null)
  peer_virtual_network_gateway_id = lookup(var.connection, "peer_network_gateway_id", null)
  local_network_gateway_id        = try(azurerm_local_network_gateway.onprem[0].id, lookup(var.connection, "local_network_gateway_id", null))

  type              = lookup(var.connection, "type", "IPsec")
  authorization_key = lookup(var.connection, "express_route_key", null)
  shared_key        = lookup(var.connection, "ipsec_key", null)

  dpd_timeout_seconds          = lookup(var.connection, "dpd_timeout_seconds", 0)
  express_route_gateway_bypass = lookup(var.connection, "express_route_gateway_bypass", false)
  connection_mode              = lookup(var.connection, "connection_mode", "Default")
  enable_bgp                   = lookup(var.connection, "enable_bgp", false)
  routing_weight               = lookup(var.connection, "routing_weight", 0)

  tags = var.tags
}

resource "azurerm_local_network_gateway" "onprem" {
  count               = var.local_network_gateway != null ? 1 : 0
  name                = lookup(var.local_network_gateway, "name")
  resource_group_name = var.resource_group_name
  location            = lookup(var.local_network_gateway, "location", azurerm_virtual_network_gateway.virtual_gateway.location)
  gateway_address     = lookup(var.local_network_gateway, "gateway_address", null)
  address_space       = lookup(var.local_network_gateway, "address_space", null)
  gateway_fqdn        = lookup(var.local_network_gateway, "gateway_fqdn", null)

  dynamic "bgp_settings" {
    for_each = lookup(var.local_network_gateway, "bgp_settings", null) != null ? [lookup(var.local_network_gateway, "bgp_settings")] : []
    content {
      asn                 = bgp_settings.value.asn
      bgp_peering_address = bgp_settings.value.bgp_peering_address
      peer_weight         = lookup(bgp_settings.value, "peer_weight", null)
    }
  }

  tags = var.tags
}
