# Create route table
resource "azurerm_route_table" "route_table" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
  tags                          = var.tags
}

# Associate subnet with route table
# Route table will be associated with subnet only after all routes are created.
resource "azurerm_subnet_route_table_association" "subnet" {
  depends_on     = [azurerm_route.route]
  for_each       = { for idx, subnet in var.subnet_associate : idx => subnet }
  subnet_id      = each.value.subnet_id
  route_table_id = azurerm_route_table.route_table.id
}

# Create routes
resource "azurerm_route" "route" {
  for_each               = { for route in var.routes : route.name => route }
  name                   = each.value.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.route_table.name
}
