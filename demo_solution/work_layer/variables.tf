variable "tfstate_backend" {
  description = <<EOF
  Remote backend configuration that will be used to get the data related to existing resources.
  backend - Terraform backend type
  backend_container_name - The Name of the Storage Container within the Storage Account.
  backend_resource_group_name - The Name of the Resource Group in which the Storage Account exists.
  backend_storage_account_name - The Name of the Storage Account.
  backend_subscription_id - The Subscription ID in which the Storage Account exists.
  backend_client_secret - The Client Secret of the Service Principal. 
  backend_client_id - The Client ID of the Service Principal. 
  backend_tenant_id - The Tenant ID in which the Subscription exists.
  backend_tfstate_file_path - Path to the deployed state file.
  EOF
  type = object({
    backend                      = optional(string, "local")
    backend_container_name       = optional(string)
    backend_resource_group_name  = optional(string)
    backend_storage_account_name = optional(string)
    backend_subscription_id      = optional(string)
    backend_client_secret        = optional(string)
    backend_client_id            = optional(string)
    backend_tenant_id            = optional(string)
    backend_tfstate_file_path    = optional(string, null)
  })
  default = null
}

variable "base_backend" {
  description = <<EOF
  Remote backend configuration that will be used to get the data related to existing resources.
  backend - Terraform backend type
  backend_container_name - The Name of the Storage Container within the Storage Account.
  backend_resource_group_name - The Name of the Resource Group in which the Storage Account exists.
  backend_storage_account_name - The Name of the Storage Account.
  backend_subscription_id - The Subscription ID in which the Storage Account exists.
  backend_client_secret - The Client Secret of the Service Principal. 
  backend_client_id - The Client ID of the Service Principal. 
  backend_tenant_id - The Tenant ID in which the Subscription exists.
  backend_tfstate_file_path_list - The list of paths to tfstate files
  EOF
  type = object({
    backend                        = optional(string, "local")
    backend_container_name         = optional(string)
    backend_resource_group_name    = optional(string)
    backend_storage_account_name   = optional(string)
    backend_subscription_id        = optional(string)
    backend_client_secret          = optional(string)
    backend_client_id              = optional(string)
    backend_tenant_id              = optional(string)
    backend_tfstate_file_path_list = optional(list(string), [])
  })
  default = null
}

variable "automation_accounts" {
  type = list(object({
    automation_account_name = string
    resource_group_name     = string
    location                = optional(string, "westeurope")
    sku                     = optional(string, "Basic")
    identity_ids            = optional(list(string), [])
    identity_type           = optional(string, "SystemAssigned")
    update_management       = optional(map(string), null)
    tags                    = optional(map(string), {})
    diagnostic_setting = optional(object({
      name                           = string
      log_analytics_workspace_id     = optional(string)
      storage_account_id             = optional(string)
      eventhub_name                  = optional(string)
      eventhub_authorization_rule_id = optional(string)
      log_category                   = optional(list(string))
      log_category_group             = optional(list(string))
      metric                         = optional(list(string))
    }), null)
    job_schedule = optional(list(object({
      runbook_name  = string
      schedule_name = string
      parameters    = map(any)
    })), [])
    module = optional(list(object({
      module_name = string
      module_link = string
    })), [])
    runbook = optional(list(object({
      runbook_name     = string
      log_verbose      = bool
      log_progress     = bool
      runbook_type     = string
      script_file_name = string
      uri              = string
    })), [])
    schedule = optional(list(object({
      schedule_name      = string
      frequency          = string
      interval           = string
      description        = string
      start_time         = string
      timezone           = string
      week_days          = list(any)
      month_days         = list(any)
      monthly_occurrence = map(string)
    })), [])
    webhook = optional(list(object({
      webhook_name        = string
      expiry_time         = string
      enabled             = bool
      runbook_name        = string
      run_on_worker_group = string
      uri                 = string
      parameters          = list(any)
    })), [])
  }))
  description = "Automation accounts parameters"
  default     = []
}

variable "public_ips" {
  type = list(object({
    name                    = string
    rg_name                 = string
    allocation_method       = optional(string, "Static")
    ddos_protection_mode    = optional(string, "VirtualNetworkInherited")
    ddos_protection_plan_id = optional(string, null)
    domain_name_label       = optional(string, null)
    idle_timeout_in_minutes = optional(number, 4)
    ip_version              = optional(string, "IPv4")
    location                = optional(string, "westeurope")
    reverse_fqdn            = optional(string, null)
    sku                     = optional(string, "Standard")
    tags                    = optional(map(string), {})
    zones                   = optional(list(string), [])
    diagnostic_setting = optional(object({
      name                           = string
      log_analytics_workspace_id     = optional(string)
      storage_account_id             = optional(string)
      eventhub_name                  = optional(string)
      eventhub_authorization_rule_id = optional(string)
      log_category                   = optional(list(string))
      log_category_group             = optional(list(string))
      metric                         = optional(list(string))
    }), null)
  }))
  description = "Public IPs parameters"
  default     = []
}

variable "nsg_list" {
  description = "NSGs parameters"
  type = list(object({
    nsg_name            = string
    location            = optional(string, "westeurope")
    resource_group_name = string
    subnet_associate = optional(list(object({
      subnet_id = string
    })), [])
    inbound_rules = optional(list(object({
      name                         = string
      priority                     = string
      protocol                     = string
      direction                    = string
      access                       = string
      description                  = optional(string)
      source_port_range            = optional(string)
      source_port_ranges           = optional(list(string))
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
      destination_asg = optional(list(object({
        name    = string
        rg_name = string
      })), [])
      source_asg = optional(list(object({
        name    = string
        rg_name = string
      })), [])
      source_application_security_group_ids      = optional(list(string))
      destination_application_security_group_ids = optional(list(string))
    })), [])
    outbound_rules = optional(list(object({
      name                         = string
      priority                     = string
      protocol                     = string
      direction                    = string
      access                       = string
      description                  = optional(string)
      source_port_range            = optional(string)
      source_port_ranges           = optional(list(string))
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
      destination_asg = optional(list(object({
        name    = string
        rg_name = string
      })), [])
      source_asg = optional(list(object({
        name    = string
        rg_name = string
      })), [])
      source_application_security_group_ids      = optional(list(string))
      destination_application_security_group_ids = optional(list(string))
    })), [])
    diagnostic_setting = optional(object({
      name                           = string
      log_analytics_workspace_id     = optional(string)
      storage_account_id             = optional(string)
      eventhub_name                  = optional(string)
      eventhub_authorization_rule_id = optional(string)
      log_category                   = optional(list(string))
      log_category_group             = optional(list(string))
    }), null)
    tags = optional(map(string), {})
  }))
  default = []
}

variable "virtual_gateways" {
  description = "List of virtual gateways to be created with parameters"
  type = list(object({
    name    = string
    rg_name = string
    ip_configuration = list(object({
      name                          = optional(string, "vnetGatewayConfig")
      private_ip_address_allocation = optional(string, "Dynamic")
      subnet_id                     = string
      public_ip_address_id          = string
    }))
    active_active         = optional(bool, false)
    connection            = optional(map(string), null)
    enable_bgp            = optional(bool, false)
    generation            = optional(string, "None")
    local_network_gateway = optional(any, null)
    location              = optional(string, "westeurope")
    sku                   = optional(string, "Basic")
    tags                  = optional(map(string), {})
    type                  = optional(string, "Vpn")
    vpn_type              = optional(string, "RouteBased")
  }))
  default = []
}

variable "private_dns_zones" {
  description = "Private DNS zones parameters"
  type = list(object({
    private_dns_zone_rg_name = string
    private_dns_zone_name    = string
    vnet_list = optional(list(object({
      virtual_network_id   = string
      registration_enabled = optional(bool, false)
    })), [])
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

variable "keyvaults" {
  description = "Key Vaults parameters"
  type = list(object({
    name                            = string
    rg_name                         = string
    location                        = optional(string, "westeurope")
    sku                             = optional(string, "standard")
    soft_delete_retention_days      = optional(string, "90")
    enabled_for_deployment          = optional(bool, false)
    enabled_for_disk_encryption     = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)
    purge_protection_enabled        = optional(bool, false)
    public_network_access_enabled   = optional(bool, true)
    enable_rbac_authorization       = optional(bool, true)
    access_policies = optional(list(object({
      object_ids              = optional(list(string))
      identity_names          = optional(list(string))
      secret_permissions      = optional(list(string), [])
      certificate_permissions = optional(list(string), [])
      key_permissions         = optional(list(string), [])
      storage_permissions     = optional(list(string), [])
    })), [])
    network_acls = optional(object({
      bypass                     = optional(string, "AzureServices")
      default_action             = optional(string, "Deny")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
      subnet_associations = optional(list(object({
        subnet_name = optional(string)
        vnet_name   = optional(string)
        rg_name     = optional(string)
      })), [])
    }))
    diagnostic_setting = optional(object({
      name                       = string
      log_analytics_workspace_id = string
      storage_account_id         = optional(string)
      log_category               = optional(list(string))
      log_category_group         = optional(list(string))
      metric                     = optional(list(string))
    }), null)
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
    })), [])
    tags = optional(map(string), {})
  }))
  default = []
}

variable "keyvaultcontents" {
  description = <<EOT
    Azure Key Vault secrets, certificates, keys data.
    Variables description could be found in the terraform.azurerm.key_vault_content module documentation.
    If you provide keyvault_id - secrets, certificates and keys data will be uploaded to the specified
    Azure Key Vault.
    EOT
  type = list(object({
    keyvault_id = optional(string)
    secrets = optional(list(object({
      name            = string
      value           = string
      content_type    = optional(string, "password")
      expiration_date = optional(string, "2027-12-31T23:59:59Z")
      not_before_date = optional(string, null)
      tags            = optional(map(string), {})
    })), [])
    keys = optional(list(object({
      name            = string
      key_type        = string
      key_size        = number
      key_opts        = list(string)
      curve           = optional(string, null)
      expiration_date = optional(string, null)
      not_before_date = optional(string, null)
      tags            = optional(map(string), {})
    })), [])
    certificate_setting = optional(list(object({
      name = string
      certificate = optional(object({
        password = optional(string, null)
        path     = string
      }), null)
      certificate_policy = optional(object({
        issuer_parameters = object({
          name = string
        })
        key_properties = object({
          curve      = optional(string, null)
          exportable = bool
          key_size   = optional(number, null)
          key_type   = string
          reuse_key  = bool
        })
        lifetime_action = optional(object({
          action = object({
            action_type = string
          })
          trigger = object({
            days_before_expiry  = optional(number, null)
            lifetime_percentage = optional(number, null)
          })
        }), null)
        secret_properties = object({
          content_type = string
        })
        x509_certificate_properties = optional(object({
          extended_key_usage = optional(list(string), [])
          key_usage          = list(string)
          subject            = string
          validity_in_months = number
          subject_alternative_names = optional(object({
            dns_names = optional(list(string), null)
            emails    = optional(list(string), null)
            upns      = optional(list(string), null)
          }), null)
        }), null)
      }), null)
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
      })), [])
      tags = optional(map(string), {})
    })), [])
  }))
  default = []
}

variable "storage_accounts" {
  description = "Storage accounts parameters"
  type = list(object({
    storage_name                    = string
    rg_name                         = string
    location                        = optional(string, "westeurope")
    access_tier                     = optional(string, "Hot")
    account_kind                    = optional(string, "StorageV2")
    account_replication_type        = optional(string, "GRS")
    account_tier                    = optional(string, "Standard")
    allow_nested_items_to_be_public = optional(bool, false)
    azure_files_authentication      = optional(any, {})
    blob_delete_retention_day       = optional(number, 7)
    change_feed_enabled             = optional(bool, false)
    large_file_share_enabled        = optional(bool, false)
    change_feed_retention_in_days   = optional(number, null)
    container_collection = optional(list(object({
      name                  = string
      container_access_type = string
    })), [])
    customer_managed_key = optional(object({
      key_name                     = string
      storage_account_id           = optional(string)
      key_vault_id                 = optional(string)
      key_vault_uri                = optional(string)
      key_version                  = optional(string)
      user_assigned_identity_id    = optional(string)
      federated_identity_client_id = optional(string)
    }), null)
    diagnostic_setting = optional(object({
      name                           = string
      log_analytics_workspace_id     = optional(string)
      storage_account_id             = optional(string)
      eventhub_name                  = optional(string)
      eventhub_authorization_rule_id = optional(string)
      metric                         = optional(list(string))
    }), null)
    enable_https_traffic_only = optional(bool, true)
    identity = optional(object({
      type         = string
      identity_ids = list(string)
    }), null)
    infrastructure_encryption_enabled = optional(bool, false)
    is_hns_enabled                    = optional(bool, false)
    logging = optional(object({
      delete                = bool
      read                  = bool
      version               = string
      write                 = bool
      retention_policy_days = optional(number)
    }), null)
    min_tls_version = optional(string, "TLS1_2")
    network_rules = optional(object({
      bypass         = string
      default_action = string
      ip_rules       = list(string)
      subnet_associations = list(object({
        subnet_name = string
        vnet_name   = string
        rg_name     = string
      }))
      external_subnet_ids = list(string)
    }), null)
    public_network_access_enabled = optional(bool, false)
    sas_policy = optional(object({
      expiration_period = string
      expiration_action = optional(string)
    }), null)
    share_collection = optional(list(object({
      name             = string
      access_tier      = string
      enabled_protocol = string
      quota            = string
    })), [])
    shared_access_key_enabled = optional(bool, true)
    versioning_enabled        = optional(bool, false)
    tags                      = optional(map(string), {})
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
    })), [])
  }))
  default = []
}

variable "privateendpoints" {
  description = "Private endpoints parameters"
  type = list(object({
    name                = string
    resource_group_name = string
    location            = optional(string, "westeurope")
    subnet_id           = string
    private_service_connection = optional(object({
      is_manual_connection              = optional(bool, false)
      private_connection_resource_id    = optional(string, null)
      private_connection_resource_alias = optional(string, null)
      subresource_names                 = optional(list(string), null)
      request_message                   = optional(string, null)
    }), {})
    private_dns_zone_group = optional(object({
      name                 = string
      private_dns_zone_ids = list(string)
    }), null)
    ip_configuration = optional(object({
      private_ip_address = string
      subresource_name   = optional(string, null)
      member_name        = optional(string, null)
    }), null)
    tags = optional(map(string), {})
  }))
  default = []
}

variable "vnet_peerings" {
  description = "List of peerings parameters to created"
  type = list(object({
    name                         = string
    remote_virtual_network_name  = string
    resource_group_name          = string
    virtual_network_name         = string
    allow_forwarded_traffic      = optional(bool, false)
    allow_gateway_transit        = optional(bool, false)
    allow_virtual_network_access = optional(bool, true)
    use_remote_gateways          = optional(bool, false)
  }))
  default = []
}

variable "azure_firewalls" {
  description = "Azure firewalls parameters"
  type = list(object({
    name                        = string
    resource_group_name         = string
    public_ip_address_id        = string
    subnet_id                   = string
    location                    = optional(string, "westeurope")
    dns_proxy_enabled           = optional(bool, false)
    dns_servers                 = optional(list(string), null)
    firewall_policy_name        = optional(string, null)
    firewall_policy_rg_name     = optional(string, null)
    management_ip_configuration = optional(list(map(string)), [])
    netw_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string
      rule = list(object({
        name                  = string
        description           = string
        source_addresses      = list(string)
        source_ip_groups      = list(string)
        destination_addresses = list(string)
        destination_ip_groups = list(string)
        destination_fqdns     = list(string)
        destination_ports     = list(string)
        protocols             = list(string)
      }))
    })), [])
    sku_name = optional(string, "AZFW_VNet")
    sku_tier = optional(string, "Standard")
    tags     = optional(map(string), {})
    zones    = optional(list(string), [])
    diagnostic_setting = optional(object({
      name                           = string
      log_analytics_workspace_id     = optional(string)
      storage_account_id             = optional(string)
      eventhub_name                  = optional(string)
      eventhub_authorization_rule_id = optional(string)
      log_category                   = optional(list(string))
      log_category_group             = optional(list(string))
      metric                         = optional(list(string))
    }), null)
  }))
  default = []
}

variable "bastion_host" {
  description = "Bastion hosts parameters"
  type = list(object({
    bastion_host_name    = string
    public_ip_address_id = string
    resource_group_name  = string
    subnet_id            = string
    copy_paste_enabled   = optional(bool, true)
    diagnostic_setting = optional(object({
      name                           = string
      log_analytics_workspace_id     = optional(string)
      storage_account_id             = optional(string)
      eventhub_name                  = optional(string)
      eventhub_authorization_rule_id = optional(string)
      log_category                   = optional(list(string))
      log_category_group             = optional(list(string))
      metric                         = optional(list(string))
    }), null)
    file_copy_enabled      = optional(bool, false)
    ip_connect_enabled     = optional(bool, false)
    location               = optional(string, "westeurope")
    scale_units            = optional(string, "2")
    shareable_link_enabled = optional(bool, false)
    sku                    = optional(string, "Basic")
    tunneling_enabled      = optional(bool, false)
    tags                   = optional(map(string), {})
  }))
  default = []
}

variable "route_tables" {
  description = "UDRs parameters"
  type = list(object({
    name                          = string
    resource_group_name           = string
    location                      = optional(string, "westeurope")
    disable_bgp_route_propagation = optional(bool, false)
    routes = list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string, null)
    }))
    subnet_associate = list(object({
      subnet_id = string
    }))
    tags = optional(map(string), {})
  }))
  default = []
}

variable "firewall_address" {
  description = "Firewall address"
  type        = string
  default     = ""
}

variable "next_hop_type" {
  description = "Next Hop Type"
  type        = string
  default     = "VirtualAppliance" # CUSTOM_LOGIC
}

variable "app_gateways" {
  description = "Application gateways parameters"
  type = list(object({
    name         = string
    rg_name      = string
    location     = optional(string, "westeurope")
    enable_http2 = optional(bool, false)
    sku = object({
      name     = string
      tier     = string
      capacity = string
    })
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

variable "vms" {
  description = <<EOT
    Azure Virtual machines configuration.
    Variables description could be found in the terraform.azurerm.vm module documentation.
    EOT
  type = list(object({
    vm_rg_name                                             = string
    vm_name                                                = string
    computer_name                                          = optional(string, null)
    vm_location                                            = optional(string, "westeurope")
    vm_size                                                = optional(string, "Standard_D4s_v3")
    zone_vm                                                = optional(string, null)
    source_custom_image_id                                 = optional(string, null)
    patch_mode                                             = optional(string, "AutomaticByOS")
    patch_assessment_mode                                  = optional(string, "ImageDefault")
    bypass_platform_safety_checks_on_user_schedule_enabled = optional(bool, false)
    source_image_reference = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = optional(string, "latest")
    }), null)
    plan = optional(object({
      name      = string
      publisher = string
      product   = string
    }), null)
    vm_admin_username       = string
    vm_admin_secret_name    = optional(string, "")
    kv_name                 = string
    kv_rg_name              = string
    vm_admin_ssh_public_key = optional(string, null)
    provision_vm_agent      = optional(bool, true)
    vm_guest_os             = optional(string, "windows")
    license_type_windows    = optional(string, "None")
    storage_account_type    = optional(string, "Standard_LRS")
    os_disk_size_gb         = optional(string, null)
    os_disk_caching         = optional(string, "ReadWrite")
    data_disks              = optional(any, null)
    vm_disk_encryption_install = optional(object({
      encryption_kek_url   = string
      encrypt_operation    = optional(string)
      volume_type          = optional(string)
      encryption_algorithm = optional(string)
    }), null)
    nic_settings = optional(list(object({
      nic_vnet_name                   = string
      nic_vnet_rg_name                = string
      nic_subnet_name                 = string
      enable_ip_forwarding            = optional(bool, false)
      enable_accelerated_networking   = optional(bool, false)
      vm_private_ip_allocation_method = optional(string, "Dynamic")
      vm_private_ip_address           = optional(string)
      lb_backend_address_pool_association = optional(object({
        lb_subscription_id           = string
        lb_name                      = string
        lb_rg_name                   = string
        lb_backend_address_pool_name = string
      }))
      public_ip = optional(object({
        vm_pip_allocation_method = optional(string, "Static")
        sku                      = optional(string, "Basic")
        zone_pip                 = optional(list(string), [])
      }))
      nsg_config = optional(object({
        nsg_association_type = string
        nsg_association_rg   = string
        nsg_association_name = string
      }))
    })))
    boot_diagnostics = optional(object({
      storage_account_uri = optional(string)
    }), null)
    diagnostic_setting = optional(object({
      diag_storage_name               = string
      diag_storage_primary_access_key = string
    }), null)
    custom_data_path                 = optional(string, null)
    vm_network_watcher_agent_install = optional(bool, false)
    post_install_script_path         = optional(string)
    ad_domain_join = optional(object({
      domain          = string
      ou_path         = optional(string)
      username        = string
      username_secret = string
    }), null)
    vm_insights = optional(object({
      workspace_id  = string
      workspace_key = string
    }), null)
    tags = optional(map(string), {})
  }))
  default = []
}

variable "backups" {
  description = "Backup Parameters"
  type = list(object({
    backup_resource_id = string
    type               = string
    vault_name         = string
    vault_rg           = string
    policy_id          = optional(string, null)
    share              = optional(string, null)
  }))
  default = []
}
