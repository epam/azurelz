# Get data of Resource Group
data "azurerm_resource_group" "appgtw" {
  count = var.location == null ? 1 : 0
  name  = var.resource_group_name
}

# Get SSL certificate data from the Azure Key Vault
data "azurerm_key_vault" "ssl_cert" {
  count               = length(var.ssl_certificates)
  name                = var.ssl_certificates[count.index].kv_name
  resource_group_name = lookup(var.ssl_certificates[count.index], "kv_rg_name", var.resource_group_name)
}

# Get Trusted Root Certificate data from the Azure Key Vault
data "azurerm_key_vault" "trust_ssl_cert" {
  count               = length(var.trusted_root_certificate)
  name                = var.trusted_root_certificate[count.index].kv_name
  resource_group_name = lookup(var.trusted_root_certificate[count.index], "kv_rg_name", var.resource_group_name)
}

# Get certificate data from key vault
data "azurerm_key_vault_certificate" "ssl_certificate" {
  count        = length(var.ssl_certificates)
  name         = var.ssl_certificates[count.index].kv_cert_name
  key_vault_id = data.azurerm_key_vault.ssl_cert[count.index].id
}

# Get Trusted Root Certificate data from key vault
data "azurerm_key_vault_certificate" "trusted_root_certificate" {
  count        = length(var.trusted_root_certificate)
  name         = var.trusted_root_certificate[count.index].kv_cert_name
  key_vault_id = data.azurerm_key_vault.trust_ssl_cert[count.index].id
}

# Get subnet to associate with Azure firewall
data "azurerm_subnet" "subnet_associate" {
  count                = length(var.gateway_ip_configurations)
  name                 = lookup(var.gateway_ip_configurations[count.index], "subnet_name", "myAGSubnet")
  virtual_network_name = var.gateway_ip_configurations[count.index].vnet_name
  resource_group_name  = lookup(var.gateway_ip_configurations[count.index], "vnet_rg_name", var.resource_group_name)
}

# Get public IP data
data "azurerm_public_ip" "public_ip" {
  count               = length(var.frontend_ip_configurations)
  name                = var.frontend_ip_configurations[count.index].public_ip_name
  resource_group_name = lookup(var.frontend_ip_configurations[count.index], "public_ip_rg_name", var.resource_group_name)
}

# Create application gateway
resource "azurerm_application_gateway" "app_gtw" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location == null ? data.azurerm_resource_group.appgtw[0].location : var.location
  zones               = var.zones
  enable_http2        = var.enable_http2
  tags                = var.tags

  dynamic "identity" {
    for_each = var.identity_ids != null ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  dynamic "ssl_certificate" {
    for_each = length(data.azurerm_key_vault_certificate.ssl_certificate) != 0 ? [1] : []
    content {
      name                = data.azurerm_key_vault_certificate.ssl_certificate[0].name
      key_vault_secret_id = data.azurerm_key_vault_certificate.ssl_certificate[0].secret_id
    }
  }

  sku {
    name     = lookup(var.sku, "name")
    tier     = lookup(var.sku, "tier")
    capacity = lookup(var.sku, "capacity", null)
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration != null ? [1] : []
    content {
      min_capacity = lookup(var.autoscale_configuration, "min_capacity")
      max_capacity = lookup(var.autoscale_configuration, "max_capacity")
    }
  }

  dynamic "gateway_ip_configuration" {
    for_each = var.gateway_ip_configurations
    content {
      name      = gateway_ip_configuration.value["name"]
      subnet_id = data.azurerm_subnet.subnet_associate[index(var.gateway_ip_configurations, gateway_ip_configuration.value)].id
    }
  }

  dynamic "frontend_port" {
    for_each = length(var.frontend_ports) != 0 ? var.frontend_ports : []
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations
    content {
      name                 = frontend_ip_configuration.value["name"]
      public_ip_address_id = data.azurerm_public_ip.public_ip[index(var.frontend_ip_configurations, frontend_ip_configuration.value)].id
    }
  }

  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificate
    iterator = trust
    content {
      name                = trust.value.kv_cert_name
      data                = lookup(trust.value, "data", null)
      key_vault_secret_id = lookup(data.azurerm_key_vault_certificate.trusted_root_certificate[index(var.trusted_root_certificate, trust.value)], "secret_id", null)
    }
  }

  # The following dynamic blocks intended to use configurations from 'app_definitions' variable. It only supports request routing rules with defined backend.
  # To set request routing rules with different configuration type, create one more instance of the following blocks and configure new variable with appropriate configuration.
  # Investigation required
  dynamic "backend_address_pool" {
    for_each = length(var.app_definitions) != 0 ? var.app_definitions : []
    content {
      name         = lookup(backend_address_pool.value.backend_address_pool, "name", "${backend_address_pool.value["app_suffix"]}-apbp")
      fqdns        = lookup(backend_address_pool.value.backend_address_pool, "fqdns", [])
      ip_addresses = lookup(backend_address_pool.value.backend_address_pool, "ip_addresses", [])
    }
  }

  dynamic "backend_http_settings" {
    for_each = length(var.app_definitions) != 0 ? var.app_definitions : []
    content {
      name                                = "${backend_http_settings.value["app_suffix"]}-apht"
      cookie_based_affinity               = lookup(backend_http_settings.value.backend_http_settings, "cookie_based_affinity", "Disabled")
      affinity_cookie_name                = lookup(backend_http_settings.value.backend_http_settings, "affinity_cookie_name", null)
      path                                = lookup(backend_http_settings.value.backend_http_settings, "path", null)
      port                                = lookup(backend_http_settings.value.backend_http_settings, "port", null)
      probe_name                          = lookup(backend_http_settings.value.backend_http_settings, "probe_name", null)
      protocol                            = lookup(backend_http_settings.value.backend_http_settings, "protocol", null)
      request_timeout                     = lookup(backend_http_settings.value.backend_http_settings, "request_timeout", 30)
      host_name                           = lookup(backend_http_settings.value.backend_http_settings, "pick_host_name_from_backend_address", false) == true ? null : lookup(backend_http_settings.value.backend_http_settings, "host_name", null)
      pick_host_name_from_backend_address = lookup(backend_http_settings.value.backend_http_settings, "pick_host_name_from_backend_address", false)
      trusted_root_certificate_names      = lookup(backend_http_settings.value.backend_http_settings, "trusted_root_certificate_names", [])

      dynamic "authentication_certificate" {
        for_each = { for cert in lookup(backend_http_settings.value.backend_http_settings, "authentication_certificate", []) : cert.name => cert }
        content {
          name = lookup(authentication_certificate.value, "name", null)
        }
      }

      dynamic "connection_draining" {
        for_each = lookup(backend_http_settings.value.backend_http_settings, "connection_draining", null) != null ? [1] : []
        content {
          enabled           = lookup(connection_draining.value, "enabled", false)
          drain_timeout_sec = lookup(connection_draining.value, "drain_timeout_sec", null)
        }
      }
    }
  }

  dynamic "http_listener" {
    for_each = length(var.app_definitions) != 0 ? var.app_definitions : []
    content {
      name                           = "${http_listener.value["app_suffix"]}-https-apls"
      frontend_ip_configuration_name = lookup(http_listener.value.http_listener, "frontend_ip_configuration_name", null)
      frontend_port_name             = lookup(http_listener.value.http_listener, "frontend_port_name", null)
      host_names                     = var.sku.tier == "Standard" ? null : lookup(http_listener.value.http_listener, "host_names", [])
      protocol                       = lookup(http_listener.value.http_listener, "protocol", null)
      require_sni                    = lookup(http_listener.value.http_listener, "require_sni", false)
      ssl_certificate_name           = lookup(http_listener.value.http_listener, "ssl_certificate_name", null)
      firewall_policy_id             = lookup(http_listener.value.http_listener, "firewall_policy_id", null)
      ssl_profile_name               = lookup(http_listener.value.http_listener, "ssl_profile_name", null)

      dynamic "custom_error_configuration" {
        for_each = { for error in lookup(http_listener.value.http_listener, "custom_error_configuration", []) : error.status_code => error }
        content {
          status_code           = lookup(custom_error_configuration.value, "status_code", null)
          custom_error_page_url = lookup(custom_error_configuration.value, "custom_error_page_url", null)
        }
      }

    }
  }

  dynamic "request_routing_rule" {
    for_each = length(var.app_definitions) != 0 ? var.app_definitions : []
    content {
      name                        = "${request_routing_rule.value["app_suffix"]}-aprl"
      rule_type                   = lookup(request_routing_rule.value.request_routing_rule, "rule_type", "Basic")
      http_listener_name          = "${request_routing_rule.value["app_suffix"]}-https-apls"
      backend_address_pool_name   = lookup(request_routing_rule.value.request_routing_rule, "rule_type", "Basic") == "Basic" ? lookup(request_routing_rule.value.request_routing_rule, "backend_address_pool_name", null) : null
      backend_http_settings_name  = lookup(request_routing_rule.value.request_routing_rule, "rule_type", "Basic") == "Basic" ? "${request_routing_rule.value["app_suffix"]}-apht" : null
      redirect_configuration_name = lookup(request_routing_rule.value.request_routing_rule, "rule_type", "Basic") == "Basic" ? lookup(request_routing_rule.value.request_routing_rule, "redirect_configuration_name", null) : null
      rewrite_rule_set_name       = lookup(request_routing_rule.value.request_routing_rule, "rule_type", "Basic") == "Basic" ? lookup(request_routing_rule.value.request_routing_rule, "rewrite_rule_set_name", null) : null
      priority                    = lookup(request_routing_rule.value.request_routing_rule, "priority", null) != null ? lookup(request_routing_rule.value.request_routing_rule, "priority", null) + length(var.app_definitions) + 100 : null
    }
  }

  dynamic "probe" {
    for_each = try(var.app_definitions.probe, null) != null ? var.app_definitions : []
    content {
      name                                      = lookup(probe.value.probe, "name", null) != null ? lookup(probe.value.probe, "name", null) : "${probe.value["app_suffix"]}-aphp"
      interval                                  = lookup(probe.value.probe, "interval", 30)
      protocol                                  = lookup(probe.value.probe, "protocol", null)
      path                                      = lookup(probe.value.probe, "path", null)
      timeout                                   = lookup(probe.value.probe, "timeout", 60)
      unhealthy_threshold                       = lookup(probe.value.probe, "unhealthy_threshold", 3)
      host                                      = lookup(probe.value.probe, "host", null)
      port                                      = lookup(probe.value.probe, "port", null)
      pick_host_name_from_backend_http_settings = lookup(probe.value.probe, "pick_host_name_from_backend_http_settings", false)
      minimum_servers                           = lookup(probe.value.probe, "minimum_servers", null)

      dynamic "match" {
        for_each = lookup(probe.value.probe, "match", null) != null ? [1] : []
        content {
          body        = lookup(probe.value.probe.match, "body", null)
          status_code = lookup(probe.value.probe.match, "status_code", [])
        }
      }
    }
  }

  dynamic "waf_configuration" {
    for_each = var.waf_configuration != null ? [var.waf_configuration] : []
    iterator = waf
    content {
      enabled          = waf.value.enabled
      firewall_mode    = lookup(waf.value, "firewall_mode", "Prevention")
      rule_set_type    = lookup(waf.value, "rule_set_type", "OWASP")
      rule_set_version = lookup(waf.value, "rule_set_version", "3.2")
    }
  }
}

# Manages a diagnostic setting for created appgtw
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_setting == null ? 0 : 1

  name                           = var.diagnostic_setting.name
  log_analytics_workspace_id     = var.diagnostic_setting.log_analytics_workspace_id
  target_resource_id             = azurerm_application_gateway.app_gtw.id
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
