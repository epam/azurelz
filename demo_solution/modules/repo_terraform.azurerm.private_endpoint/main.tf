locals {
  private_connection_resource_name = try(split("/", var.private_service_connection.private_connection_resource_id)[length(split("/", var.private_service_connection.private_connection_resource_id)) - 1], var.private_service_connection.private_connection_resource_alias)
}

data "azurerm_resource_group" "rg" {
  count = var.location == null ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_private_endpoint" "endpoint" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location == null ? data.azurerm_resource_group.rg[0].location : var.location
  subnet_id           = var.subnet_id

  private_service_connection {
    name                              = format("%s-connection", local.private_connection_resource_name)
    is_manual_connection              = var.private_service_connection.is_manual_connection
    private_connection_resource_id    = var.private_service_connection.private_connection_resource_id
    private_connection_resource_alias = var.private_service_connection.private_connection_resource_alias
    subresource_names                 = var.private_service_connection.subresource_names
    request_message                   = var.private_service_connection.request_message
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_group != null ? [1] : []
    content {
      name                 = var.private_dns_zone_group.name
      private_dns_zone_ids = var.private_dns_zone_group.private_dns_zone_ids
    }
  }

  dynamic "ip_configuration" {
    for_each = var.ip_configuration != null ? [1] : []
    content {
      name               = format("%s-ip-configuration", local.private_connection_resource_name)
      private_ip_address = var.ip_configuration.private_ip_address
      subresource_name   = var.ip_configuration.subresource_name != null ? var.ip_configuration.subresource_name : var.private_service_connection.subresource_names[0]
      member_name        = var.ip_configuration.member_name
    }
  }

  tags = var.tags
}
