# Backend configuration for using base layer data
variable "backend_tfstate_file_path" {
  description = "Path to the deployed state file."
  type        = string
  default     = null
}
variable "backend_tfstate_file_path_list" {
  description = "The list of paths to tfstate files"
  type        = list(string)
}

# 020_automationaccount
variable "automation_accounts" {
  type        = any
  description = "Automation accounts parameters"
  default     = []
}

# 025_publicip
variable "public_ips" {
  type        = any
  description = "Public IPs parameters"
  default     = []
}

# 030_nsg
variable "nsgs" {
  type        = any
  description = "NSGs parameters"
  default     = []
}

# 030_virtualgtw
variable "virtual_gateways" {
  description = "List of virtual gateways to be created with parameters"
  type        = any
  default     = []
}

# 030_privatedns
variable "private_dns_zones" {
  description = "Private DNS zones parameters"
  type = list(object({
    private_dns_zone_rg_name = string
    private_dns_zone_name    = string
    vnet_list = list(object({
      virtual_network_id   = string
      registration_enabled = optional(bool, false)
    }))
    records = optional(object({
      soa_records = optional(list(object({
        email        = string
        expire_time  = optional(number, 2419200)
        minimum_ttl  = optional(number, 10)
        refresh_time = optional(number, 3600)
        retry_time   = optional(number, 300)
        ttl          = optional(number, 3600)
      })), [])
      a_records = optional(list(object({
        name    = string
        ttl     = string
        records = list(string)
      })), [])
      aaaa_records = optional(list(object({
        name    = string
        ttl     = string
        records = list(string)
      })), [])
      cname_records = optional(list(object({
        name   = string
        ttl    = string
        record = string
      })), [])
      mx_records = optional(list(object({
        name = string
        ttl  = string
        record = list(object({
          preference = string
          exchange   = string
        }))
      })), [])
      ptr_records = optional(list(object({
        name    = string
        ttl     = string
        records = list(string)
      })), [])
      srv_records = optional(list(object({
        name = string
        ttl  = string
        record = list(object({
          priority = string
          weight   = string
          port     = string
          target   = string
        }))
      })), [])
      txt_records = optional(list(object({
        name = string
        ttl  = string
        record = list(object({
          value = string
        }))
      })), [])
    }))
    tags = optional(map(string), {})
  }))
  default = []
}

# 035_keyvault
variable "keyvaults" {
  description = "Key Vaults parameters"
  type = list(object({
    name                            = string
    rg_name                         = string
    sku                             = optional(string, "standard")
    soft_delete_retention_days      = optional(string, "90")
    enabled_for_deployment          = optional(bool, false)
    enabled_for_disk_encryption     = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)
    purge_protection_enabled        = optional(bool, false)
    enable_rbac_authorization       = optional(bool, false)
    access_policies = optional(list(object({
      object_ids              = optional(list(string))
      identity_names          = optional(list(string))
      secret_permissions      = optional(list(string), [])
      certificate_permissions = optional(list(string), [])
      key_permissions         = optional(list(string), [])
      storage_permissions     = optional(list(string), [])
    })))
    rbac = optional(list(object({
      principal_id  = optional(string)
      identity_name = optional(string)
      assigment = optional(object({
        scope                = string
        description          = optional(string)
        name                 = optional(string)
        role_definition_name = optional(string)
        condition            = optional(string)
        condition_version    = optional(string)
      }))
      definition = optional(object({
        name               = string
        scope              = string
        description        = optional(string)
        role_definition_id = optional(string)
        assignable_scopes  = optional(list(string), null)
        permissions = optional(object({
          actions          = optional(list(string))
          data_actions     = optional(list(string))
          not_actions      = optional(list(string))
          not_data_actions = optional(list(string))
        }), null)
      }))
    })))
    network_acls = optional(object({
      bypass         = optional(string, "AzureServices")
      default_action = optional(string, "Allow")
      ip_rules       = optional(list(string), [])
      subnet_associations = optional(list(object({
        subnet_name = optional(string)
        vnet_name   = optional(string)
        rg_name     = optional(string)
      })), [])
    }))
    diagnostic_setting = optional(object({
      name                       = string
      log_analytics_workspace_id = string
      storage_account_id         = string
      log_category               = optional(list(string))
      metric                     = optional(list(string))
    }))
    tags = optional(map(string), {})
  }))
  default = []
}

# 035_keyvaultcontent
variable "keyvaultcontents" {
  description = "Key Vault contents parameters"
  type        = any
  default     = []
}

# 035_storageaccount
variable "storage_accounts" {
  description = "Storage accounts parameters"
  type        = any
  default     = []
}

# 035_vnetpeering
variable "vnet_peerings" {
  description = "List of the map of peerings parameters to created"
  type        = any
  default     = null
}

# 045_azurefirewall
variable "azure_firewalls" {
  description = "Azure firewalls parameters"
  type        = any
  default     = []
}

# 050_bastionhost
variable "bastion_host" {
  description = "Bastion hosts parameters"
  type        = any
  default     = []
}

# 050_udr
variable "route_tables" {
  description = "UDRs parameters"
  type        = any
  default     = []
}
variable "firewall_address" {
  description = "Fifewall address"
  type        = string
  default     = ""
}

# 055_appgtw
variable "app_gateways" {
  description = "Application gateways parameters"
  type = list(object({
    name         = string
    rg_name      = string
    location     = optional(string)
    enable_http2 = optional(bool, false)
    sku = optional(object({
      name     = string
      tier     = string
      capacity = string
    }))
    identity_ids = optional(list(string))
    gateway_ip_configurations = list(object({
      name         = string
      subnet_name  = string
      vnet_name    = string
      vnet_rg_name = string
    }))
    frontend_ip_configurations = list(object({
      name              = string
      public_ip_name    = string
      public_ip_rg_name = string
    }))
    zones = optional(list(string), [])
    autoscale_configuration = optional(object({
      min_capacity = string
      max_capacity = string
    }))
    frontend_ports = list(object({
      name = string
      port = string
    }))
    ssl_certificates = optional(list(object({
      kv_name      = string
      kv_rg_name   = string
      kv_cert_name = string
    })), [])
    trusted_root_certificate = optional(list(object({
      kv_name      = string
      kv_rg_name   = string
      kv_cert_name = string
      data         = string
    })), [])
    app_definitions = list(object({
      app_suffix = optional(string, "myapp")
      backend_address_pool = object({
        name         = string
        fqdns        = optional(list(string))
        ip_addresses = optional(list(string))
      })
      backend_http_settings = object({
        cookie_based_affinity               = optional(string, "Disabled")
        affinity_cookie_name                = optional(string)
        path                                = optional(string)
        port                                = string
        probe_name                          = optional(string)
        protocol                            = string
        request_timeout                     = optional(number, 30)
        host_name                           = optional(string)
        pick_host_name_from_backend_address = optional(bool, false)
        trusted_root_certificate_names      = optional(list(string))
        authentication_certificate = optional(list(object({
          name = string
        })), [])
        connection_draining = optional(object({
          enabled           = bool
          drain_timeout_sec = number
        }))
      })
      http_listener = object({
        frontend_ip_configuration_name = string
        frontend_port_name             = string
        host_names                     = optional(list(string))
        protocol                       = string
        require_sni                    = optional(bool, false)
        ssl_certificate_name           = optional(string)
        custom_error_configuration = optional(list(object({
          status_code           = string
          custom_error_page_url = string
        })), [])
        firewall_policy_id = optional(string)
        ssl_profile_name   = optional(string)
      })
      request_routing_rule = object({
        rule_type                   = optional(string, "Basic")
        redirect_configuration_name = optional(string)
        rewrite_rule_set_name       = optional(string)
        priority                    = optional(number, 100)
        backend_address_pool_name   = optional(string)
      })
      probe = optional(object({
        host                                      = optional(string)
        name                                      = optional(string)
        interval                                  = optional(number, 30)
        protocol                                  = string
        path                                      = string
        timeout                                   = optional(number, 60)
        unhealthy_threshold                       = optional(number, 3)
        port                                      = optional(number)
        pick_host_name_from_backend_http_settings = optional(bool, false)
        match = optional(object({
          body        = optional(string)
          status_code = list(string)
        }))
        minimum_servers = optional(number, 0)
      }))
    }))
    waf_configuration = optional(object({
      enabled          = bool
      firewall_mode    = string
      rule_set_type    = string
      rule_set_version = string
    }))
    diagnostic_setting = optional(object({
      name                       = string
      log_analytics_workspace_id = string
      storage_account_id         = string
      log_category               = optional(list(string))
      metric                     = optional(list(string))
    }))
    tags = optional(map(string), {})
  }))
  default = []
}

# 060_vm
variable "vms" {
  type        = any
  description = "VMs parameters"
  default     = []
}
