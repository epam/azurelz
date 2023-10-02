# Create route table
resource "azurerm_route_table" "route_table" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
  tags                          = var.tags
}

# Get subnet to associate with route table
data "azurerm_subnet" "subnet_associate" {
  for_each             = { for subnet in var.subnet_associate : subnet.subnet_name => subnet }
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = lookup(each.value, "rg_name", var.resource_group_name)
}

# Associate subnet with route table
# Route table will be associated with subnet only after all routes are created, it significant for subnets such as AzureBastion.
resource "azurerm_subnet_route_table_association" "subnet" {
  for_each       = { for subnet in var.subnet_associate : subnet.subnet_name => subnet }
  depends_on     = [azurerm_route.route]
  subnet_id      = data.azurerm_subnet.subnet_associate[each.value.subnet_name].id
  route_table_id = azurerm_route_table.route_table.id
}

# Create routes
resource "azurerm_route" "route" {
  for_each               = { for route in var.routes : route.name => route }
  name                   = each.value.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = lookup(each.value, "next_hop_in_ip_address", null)
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.route_table.name
}
