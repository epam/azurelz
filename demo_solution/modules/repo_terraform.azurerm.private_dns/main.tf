# Create a private DNS zone
resource "azurerm_private_dns_zone" "private_dns" {
  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_rg_name
  tags                = var.tags

  dynamic "soa_record" {
    for_each = var.records != null ? { for soa in var.records.soa_records : soa.soa_email_contact => soa } : {}
    content {
      email        = soa_record.value.email
      expire_time  = soa_record.value.expire_time
      minimum_ttl  = soa_record.value.minimum_ttl
      refresh_time = soa_record.value.refresh_time
      retry_time   = soa_record.value.retry_time
      ttl          = soa_record.value.ttl
      tags         = var.tags
    }
  }
}

# Create a link to VNET
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  # Get VNET name from VNET ID and build the map
  for_each              = { for vnet in var.vnet_list : element(split("/", vnet.virtual_network_id), length(split("/", vnet.virtual_network_id)) - 1) => vnet }
  name                  = "${each.key}-network-link"
  resource_group_name   = azurerm_private_dns_zone.private_dns.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled
  tags                  = var.tags
}

# Create a DNS A Records within Azure Private DNS
resource "azurerm_private_dns_a_record" "a_records" {
  for_each            = var.records != null ? { for a in var.records.a_records : a.name => a } : {}
  name                = each.value.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  zone_name           = azurerm_private_dns_zone.private_dns.name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = var.tags
}

# Create a DNS AAAA Records within Azure Private DNS
resource "azurerm_private_dns_aaaa_record" "aaaa_records" {
  for_each            = var.records != null ? { for aaaa in var.records.aaaa_records : aaaa.name => aaaa } : {}
  name                = each.value.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  zone_name           = azurerm_private_dns_zone.private_dns.name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = var.tags
}

# Create a DNS CNAME Records within Azure Private DNS
resource "azurerm_private_dns_cname_record" "cname_records" {
  for_each            = var.records != null ? { for cname in var.records.cname_records : cname.name => cname } : {}
  name                = each.value.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  zone_name           = azurerm_private_dns_zone.private_dns.name
  ttl                 = each.value.ttl
  record              = each.value.record
  tags                = var.tags
}

# Create a DNS MX Records within Azure Private DNS
resource "azurerm_private_dns_mx_record" "mx_records" {
  for_each            = var.records != null ? { for mx in var.records.mx_records : mx.name => mx } : {}
  name                = each.value.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  zone_name           = azurerm_private_dns_zone.private_dns.name
  ttl                 = each.value.ttl
  tags                = var.tags

  dynamic "record" {
    for_each = { for rec in each.value.record : rec.preference => rec }
    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }
}

# Create a DNS PTR Records within Azure Private DNS
resource "azurerm_private_dns_ptr_record" "ptr_records" {
  for_each            = var.records != null ? { for ptr in var.records.ptr_records : ptr.name => ptr } : {}
  name                = each.value.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  zone_name           = azurerm_private_dns_zone.private_dns.name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = var.tags
}

# Create a DNS SRV Records within Azure Private DNS
resource "azurerm_private_dns_srv_record" "srv_records" {
  for_each            = var.records != null ? { for srv in var.records.srv_records : srv.name => srv } : {}
  name                = each.value.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  zone_name           = azurerm_private_dns_zone.private_dns.name
  ttl                 = each.value.ttl
  tags                = var.tags

  dynamic "record" {
    for_each = { for rec in each.value.record : rec.target => rec }
    content {
      priority = record.value.priority
      weight   = record.value.weight
      port     = record.value.port
      target   = record.value.target
    }
  }
}

# Create a DNS TXT Records within Azure Private DNS
resource "azurerm_private_dns_txt_record" "txt_records" {
  for_each            = var.records != null ? { for txt in var.records.txt_records : txt.name => txt } : {}
  name                = each.value.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  zone_name           = azurerm_private_dns_zone.private_dns.name
  ttl                 = each.value.ttl
  tags                = var.tags

  dynamic "record" {
    for_each = { for rec in each.value.record : rec.value => rec }
    content {
      value = record.value.value
    }
  }
}
