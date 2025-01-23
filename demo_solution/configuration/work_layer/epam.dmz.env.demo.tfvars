tfstate_backend = {
  backend_tfstate_file_path = "../base_layer/terraform.tfstate.d/epam.dmz.env.demo/terraform.tfstate",
}

base_backend = {
  backend_tfstate_file_path_list = [
    "../base_layer/terraform.tfstate.d/epam.business.env.demo/terraform.tfstate",
    "../base_layer/terraform.tfstate.d/epam.dmz.env.demo/terraform.tfstate",
    "../base_layer/terraform.tfstate.d/epam.gateway.env.demo/terraform.tfstate",
    "../base_layer/terraform.tfstate.d/epam.identity.env.demo/terraform.tfstate",
    "../base_layer/terraform.tfstate.d/epam.shared.env.demo/terraform.tfstate"
  ]
}

public_ips = [
  {
    name              = "dmz-pip-weeu-s-dmzapgt-01"
    rg_name           = "dmz-rg-weeu-s-network-01"
    allocation_method = "Static"
    sku               = "Standard"
    zones             = ["1", "2", "3"]
    ip_version        = "IPv4"
    domain_name_label = "dmz-pip-weeu-dmz-appgtw-011"

    diagnostic_setting = {
      name                       = "dmz-pip-weeu-s-dmzapgt-diag"
      log_analytics_workspace_id = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/dmz-la-weeu-p-centralnetworking-01"
      storage_account_id         = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/dmzstrpcnetworkingla0001"
      log_category               = ["DDoSProtectionNotifications", "DDoSMitigationFlowLogs", "DDoSMitigationReports"]
      metric                     = ["AllMetrics"]
    }

    tags = {
      environment         = ""
      businessCriticality = ""
      businessUnit        = ""
      businessOwner       = ""
      platfromSupport     = ""
      functionalSupport   = ""
      reviewedOn          = ""
    }
  }
]

nsg_list = [
  {
    nsg_name            = "dmz-nsg-weeu-s-net-appgtw"
    location            = "westeurope"
    resource_group_name = "dmz-rg-weeu-s-network-01"

    diagnostic_setting = {
      name                       = "dmz-nsg-weeu-s-net-appgtw-diag"
      log_analytics_workspace_id = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/dmz-la-weeu-p-centralnetworking-01"
      storage_account_id         = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/dmzstrpcnetworkingla0001"
      log_category               = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
    }

    subnet_associate = [
      {
        subnet_id = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-network-01/providers/Microsoft.Network/virtualNetworks/dmz-vnet-weeu-s-spoke-01/subnets/ApplicationGatewaySubnet"
      }
    ]

    inbound_rules = [
      {
        name                       = "AllowGWM"
        direction                  = "Inbound"
        priority                   = "100"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "GatewayManager"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_range     = "65200-65535"
      },
      {
        name                       = "AllowAzureLoadBalancer"
        direction                  = "Inbound"
        priority                   = "110"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "AzureLoadBalancer"
        source_port_range          = "*"
        destination_address_prefix = "virtualNetwork"
        destination_port_range     = "*"
      },
      {
        name                       = "DenyVnetInBound"
        direction                  = "Inbound"
        priority                   = "4096"
        access                     = "Deny"
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "virtualNetwork"
        destination_port_range     = "*"
      }
    ]

    outbound_rules = []

    tags = {
      environment         = ""
      businessCriticality = ""
      businessUnit        = ""
      businessOwner       = ""
      platfromSupport     = ""
      functionalSupport   = ""
      reviewedOn          = ""
    }
  },
  {
    nsg_name            = "dmz-nsg-weeu-s-net-vm"
    location            = "westeurope"
    resource_group_name = "dmz-rg-weeu-s-network-01"

    subnet_associate = [
      {
        subnet_id = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-network-01/providers/Microsoft.Network/virtualNetworks/dmz-vnet-weeu-s-spoke-01/subnets/sn-core-01"
      }
    ]
    inbound_rules = [
      {
        name                       = "AllowPublicConnection"
        direction                  = "Inbound"
        priority                   = "100"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "Internet"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_range     = "443"
      },
      {
        name                       = "AllowGWM"
        direction                  = "Inbound"
        priority                   = "120"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "GatewayManager"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_range     = "443"
      },
      {
        name                       = "AllowAzureLoadBalancer"
        direction                  = "Inbound"
        priority                   = "130"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "AzureLoadBalancer"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_range     = "443"
      },
      {
        name                       = "AllowBastion"
        direction                  = "Inbound"
        priority                   = "140"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "virtualNetwork"
        source_port_range          = "*"
        destination_address_prefix = "virtualNetwork"
        destination_port_ranges = [
          "8080",
          "5701"
        ]
      }
    ]
    outbound_rules = [
      {
        name                       = "AllowSshPdpOutbound"
        direction                  = "Outbound"
        priority                   = "100"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "virtualNetwork"
        destination_port_ranges = [
          "3389",
          "22"
        ]
      },
      {
        name                       = "AllowAzureCloudOutbound"
        direction                  = "Outbound"
        priority                   = "110"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "AzureCloud"
        destination_port_range     = "443"
      },
      {
        name                       = "AllowBastionCommunication"
        direction                  = "Outbound"
        priority                   = "120"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "virtualNetwork"
        source_port_range          = "*"
        destination_address_prefix = "virtualNetwork"
        destination_port_ranges = [
          "8080",
          "5701"
        ]
      },
      {
        name                       = "AllowGetSessionInformation"
        direction                  = "Outbound"
        priority                   = "130"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "Internet"
        destination_port_range     = "80"
      }
    ]
    tags = {
      environment         = ""
      businessCriticality = ""
      businessUnit        = ""
      businessOwner       = ""
      platfromSupport     = ""
      functionalSupport   = ""
      reviewedOn          = ""
    }
  }
]

keyvaults = [
  {
    name                            = "dmz-kv-weeu-s-sh-dmz-01"
    rg_name                         = "dmz-rg-weeu-s-infra-01"
    sku                             = "standard"
    soft_delete_enabled             = false
    soft_delete_retention_days      = "90"
    enabled_for_deployment          = true
    enabled_for_disk_encryption     = true
    enabled_for_template_deployment = true
    purge_protection_enabled        = false
    enable_rbac_authorization       = true
    network_acls = {
      bypass         = "AzureServices"
      default_action = "Allow"
      ip_rules       = []
      subnet_associations = [
        {
          subnet_name = "sn-core-01"
          vnet_name   = "dmz-vnet-weeu-s-spoke-01"
          rg_name     = "dmz-rg-weeu-s-network-01"
        }
      ]
    }
    rbac = [
      {
        principal_id = "7bca97c4-40de-41e3-a290-a3586a277841"
        assigment = {
          role_definition_name = "Key Vault Administrator"
          description          = "Assigment the KeyVault administrator role"
          scope                = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/dmz-kv-weeu-s-sh-dmz-01"
        }
      },
      {
        identity_name = "dmz-demo-identity-01"
        assigment = {
          role_definition_name = "Key Vault Administrator"
          description          = "Assigment the KeyVault administrator role"
          scope                = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/dmz-kv-weeu-s-sh-dmz-01"
        }
      }
    ]
    diagnostic_setting = {
      name                       = "dmz-kv-weeu-s-sh-dmz-01-diag"
      log_analytics_workspace_id = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/dmz-la-weeu-p-centralnetworking-01"
      storage_account_id         = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/dmzstrpcnetworkingla0001"
      log_category               = ["AuditEvent", "AzurePolicyEvaluationDetails"]
      metric                     = ["AllMetrics"]
    }
    tags = {
      environment         = ""
      businessCriticality = ""
      businessUnit        = ""
      businessOwner       = ""
      platfromSupport     = ""
      functionalSupport   = ""
      reviewedOn          = ""
    }
  },
  {
    name                            = "dmz-kv-weeu-s-app-dmz-01"
    rg_name                         = "dmz-rg-weeu-s-infra-01"
    sku                             = "standard"
    soft_delete_enabled             = false
    soft_delete_retention_days      = "90"
    enabled_for_deployment          = true
    enabled_for_disk_encryption     = true
    enabled_for_template_deployment = true
    purge_protection_enabled        = false
    enable_rbac_authorization       = true
    network_acls = {
      bypass         = "AzureServices"
      default_action = "Allow"
      ip_rules       = []

      subnet_associations = [
        {
          subnet_name = "sn-core-01"
          vnet_name   = "dmz-vnet-weeu-s-spoke-01"
          rg_name     = "dmz-rg-weeu-s-network-01"
        }
      ]
    }
    rbac = [
      {
        principal_id = "7bca97c4-40de-41e3-a290-a3586a277841"
        assigment = {
          role_definition_name = "Key Vault Administrator"
          description          = "Assigment the KeyVault administrator role"
          scope                = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/dmz-kv-weeu-s-app-dmz-01"
        }
      }
    ]
    diagnostic_setting = {
      name                       = "dmz-kv-weeu-s-app-dmz-01-diag"
      log_analytics_workspace_id = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/dmz-la-weeu-p-centralnetworking-01"
      storage_account_id         = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/dmzstrpcnetworkingla0001"
      log_category               = ["AuditEvent", "AzurePolicyEvaluationDetails"]
      metric                     = ["AllMetrics"]
    }
    tags = {
      environment         = ""
      businessCriticality = ""
      businessUnit        = ""
      businessOwner       = ""
      platfromSupport     = ""
      functionalSupport   = ""
      reviewedOn          = ""
    }
  }
]

keyvaultcontents = [
  {
    keyvault_id = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/dmz-kv-weeu-s-sh-dmz-01"
    secrets = [
      {
        name  = "epamuser"
        value = "My$ecureP@ss"
      }
    ]
    certificate_setting = [
      {
        name = "wildcard-xapps-online"
        certificate_policy = {
          issuer_parameters = {
            name = "Self"
          }
          key_properties = {
            exportable = true
            key_size   = 2048
            key_type   = "RSA"
            reuse_key  = true
          }
          lifetime_action = {
            action = {
              action_type = "AutoRenew"
            }
            trigger = {
              days_before_expiry = 30
            }
          }
          secret_properties = {
            content_type = "application/x-pkcs12"
          }
          x509_certificate_properties = {
            extended_key_usage = ["1.3.6.1.5.5.7.3.1"]
            key_usage = [
              "cRLSign",
              "dataEncipherment",
              "digitalSignature",
              "keyAgreement",
              "keyCertSign",
              "keyEncipherment",
            ]
            subject            = "CN=LandingZone"
            validity_in_months = 12
            subject_alternative_names = {
              dns_names = ["wildcard.xapps.online"]
            }
          }
        }
        tags = {
          env = "dev"
        }
      }
    ]
  },
  {
    keyvault_id = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/dmz-kv-weeu-s-app-dmz-01"
    kv_name     = "dmz-kv-weeu-s-app-dmz-01"

    secrets = [
      {
        name  = "secret"
        value = "My$ecureP@ss"
      }
    ]
    rbac = [
      {
        name = "KeyVaultSecretsOfficer"
        role_assignments = {
          assigment = {
            role_definition_name = "Key Vault Secrets Officer"
            description          = "Perform any action on the secrets of a key vault, except manage permissions."
            scope                = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/dmz-kv-weeu-s-app-dmz-01/secrets/secret"
          }
          principal_id = "7bca97c4-40de-41e3-a290-a3586a277841"
        }
      }
    ]
  }
]

vnet_peerings = [
  {
    name                         = "dmz-peer-weeu-s-dmz-gat-01"
    virtual_network_name         = "dmz-vnet-weeu-s-spoke-01"
    resource_group_name          = "dmz-rg-weeu-s-network-01"
    remote_virtual_network_name  = "gat-vnet-weeu-s-hub-01"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
  }
]

app_gateways = [
  {
    name         = "dmz-apgt-weeu-s-01"
    location     = "westeurope"
    rg_name      = "dmz-rg-weeu-s-network-01"
    enable_http2 = false
    sku = {
      name     = "WAF_v2"
      tier     = "WAF_v2"
      capacity = null
    }
    identity_ids = ["/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-network-01/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dmz-demo-identity-01"]
    gateway_ip_configurations = [
      {
        name         = "gateway_ip_configuration_01"
        subnet_name  = "ApplicationGatewaySubnet"
        vnet_name    = "dmz-vnet-weeu-s-spoke-01"
        vnet_rg_name = "dmz-rg-weeu-s-network-01"
      }
    ]
    frontend_ip_configurations = [
      {
        name              = "public"
        public_ip_name    = "dmz-pip-weeu-s-dmzapgt-01"
        public_ip_rg_name = "dmz-rg-weeu-s-network-01"
      }
    ]
    zones = [
      "1",
      "2",
      "3"
    ]
    autoscale_configuration = {
      min_capacity = "0"
      max_capacity = "2"
    }
    frontend_ports = [
      {
        name = "Port_443"
        port = "443"
      }
    ]
    ssl_certificates = [
      {
        kv_name      = "dmz-kv-weeu-s-sh-dmz-01"
        kv_rg_name   = "dmz-rg-weeu-s-infra-01"
        kv_cert_name = "wildcard-xapps-online"
      }
    ]
    app_definitions = [
      {
        app_suffix = "app01"
        backend_address_pool = {
          name         = "app01-apbp"
          fqdns        = ["app-epam-cnp-webapp-westeurope-dev.azurewebsites.net"]
          ip_addresses = []
        }
        backend_http_settings = {
          cookie_based_affinity               = "Enabled"
          affinity_cookie_name                = null
          path                                = null
          port                                = "443"
          protocol                            = "Https"
          request_timeout                     = "300"
          host_name                           = null
          pick_host_name_from_backend_address = true
          authentication_certificate          = []
          trusted_root_certificate_names      = []
          connection_draining                 = null
        }
        http_listener = {
          frontend_ip_configuration_name = "public"
          frontend_port_name             = "Port_443"
          host_names                     = ["myapp.xapps.online"]
          protocol                       = "Https"
          require_sni                    = false
          ssl_certificate_name           = "wildcard-xapps-online"
          custom_error_configuration     = []
          firewall_policy_id             = null
          ssl_profile_name               = null
        }
        request_routing_rule = {
          backend_address_pool_name = "app01-apbp"
          rule_type                 = "Basic"
          priority                  = "10"
        }
        probe = {
          host                                      = null
          interval                                  = "30"
          protocol                                  = "Https"
          path                                      = "/"
          timeout                                   = 30
          unhealthy_threshold                       = 3
          port                                      = null
          pick_host_name_from_backend_http_settings = true
          match                                     = null
          minimum_servers                           = null
        }
      }
    ]
    waf_configuration = {
      enabled          = true
      firewall_mode    = "Prevention"
      rule_set_type    = "OWASP"
      rule_set_version = "3.2"
    }
    diagnostic_setting = {
      name                       = "dmz-apgt-weeu-s-01-diag"
      log_analytics_workspace_id = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/dmz-la-weeu-p-centralnetworking-01"
      storage_account_id         = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/dmzstrpcnetworkingla0001"
      log_category               = ["ApplicationGatewayAccessLog", "ApplicationGatewayFirewallLog", "ApplicationGatewayPerformanceLog"]
      metric                     = ["AllMetrics"]
    }
    tags = {
      environment         = ""
      businessCriticality = ""
      businessUnit        = ""
      businessOwner       = ""
      platfromSupport     = ""
      functionalSupport   = ""
      reviewedOn          = ""
    }
  }
]

vms = [
  {
    vm_name                          = "vmdmz01"
    vm_rg_name                       = "dmz-rg-weeu-s-compute-01"
    vm_size                          = "Standard_B2s_v2" //"Standard_D2s_v3" is unabailable in westeurope
    vm_admin_username                = "epamuser"
    admin_secret_kv_name             = "dmz-kv-weeu-s-sh-dmz-01"
    admin_secret_kv_rg_name          = "dmz-rg-weeu-s-infra-01"
    kv_name                          = "dmz-kv-weeu-s-sh-dmz-01"
    kv_rg_name                       = "dmz-rg-weeu-s-infra-01"
    zone_vm                          = "1"
    vm_guest_os                      = "windows"
    license_type_windows             = "Windows_Server"
    storage_account_type             = "Premium_LRS"
    os_disk_size_gb                  = 128
    vm_network_watcher_agent_install = false
    data_disks = {
      DATAD002 = {
        storage_account_type = "Standard_LRS"
        disk_size_gb         = 40
        caching              = "None"
        lun                  = 10
      }
    }
    nic_settings = [
      {
        nic_vnet_name                   = "dmz-vnet-weeu-s-spoke-01"
        nic_vnet_rg_name                = "dmz-rg-weeu-s-network-01"
        nic_subnet_name                 = "sn-core-01"
        enable_ip_forwarding            = false
        enable_accelerated_networking   = true
        vm_private_ip_allocation_method = "Static"
        vm_private_ip_address           = "10.1.81.10"
      }
    ]
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
    }
    tags = {
      environment         = "dev"
      businessCriticality = ""
      businessUnit        = "IT"
      businessOwner       = "WBS"
      platfromSupport     = "Node01"
      functionalSupport   = ""
      reviewedOn          = ""
    }
  }
]
