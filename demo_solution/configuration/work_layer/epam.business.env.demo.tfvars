base_backend = {
  backend_tfstate_file_path_list = [
    "../base_layer/terraform.tfstate.d/epam.business.env.demo/terraform.tfstate",
    "../base_layer/terraform.tfstate.d/epam.dmz.env.demo/terraform.tfstate",
    "../base_layer/terraform.tfstate.d/epam.gateway.env.demo/terraform.tfstate",
    "../base_layer/terraform.tfstate.d/epam.identity.env.demo/terraform.tfstate",
    "../base_layer/terraform.tfstate.d/epam.shared.env.demo/terraform.tfstate"
  ]
}

nsg_list = [
  {
    nsg_name            = "demo-nsg-weeu-s-bs-vm"
    location            = "westeurope"
    resource_group_name = "bus-rg-weeu-s-network-01"
    subnet_associate = [
      {
        subnet_id = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-network-01/providers/Microsoft.Network/virtualNetworks/bus-vnet-weeu-s-spoke-01/subnets/sn-core-01"
      }
    ]
    inbound_rules = [
      {
        name                       = "AllowAzureLoadBalancer"
        direction                  = "Inbound"
        priority                   = "100"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "AzureLoadBalancer"
        source_port_range          = "*"
        destination_address_prefix = "virtualNetwork"
        destination_port_range     = "*"
      }
    ]
    outbound_rules = []
    diagnostic_setting = {
      name                       = "demo-nsg-weeu-s-bs-vm-diag"
      log_analytics_workspace_id = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/bus-la-weeu-p-central-01"
      storage_account_id         = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/busstrpcentralla0001"
      log_category               = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
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

keyvaults = [
  {
    name                            = "bus-kv-weeu-s-sh-bus-01"
    rg_name                         = "bus-rg-weeu-s-infra-01"
    sku                             = "standard"
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
          vnet_name   = "bus-vnet-weeu-s-spoke-01"
          rg_name     = "bus-rg-weeu-s-network-01"
        }
      ]
    }
    rbac = [
      {
        principal_id = "7bca97c4-40de-41e3-a290-a3586a277841"
        assigment = {
          role_definition_name = "Key Vault Administrator"
          description          = "Assigment the KeyVault administrator role"
          scope                = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/bus-kv-weeu-s-sh-bus-01"
        }
      }
    ]
    diagnostic_setting = {
      name                       = "bus-kv-weeu-s-sh-bus-01-giag"
      log_analytics_workspace_id = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/bus-la-weeu-p-central-01"
      storage_account_id         = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/busstrpcentralla0001"
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
    name                            = "bus-kv-weeu-s-app-bus-01"
    rg_name                         = "bus-rg-weeu-s-infra-01"
    sku                             = "standard"
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
          vnet_name   = "bus-vnet-weeu-s-spoke-01"
          rg_name     = "bus-rg-weeu-s-network-01"
        }
      ]
    }
    rbac = [
      {
        principal_id = "7bca97c4-40de-41e3-a290-a3586a277841"
        assigment = {
          role_definition_name = "Key Vault Administrator"
          description          = "Assigment the KeyVault administrator role"
          scope                = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/bus-kv-weeu-s-app-bus-01"
        }
      }
    ]
    diagnostic_setting = {
      name                       = "bus-kv-weeu-s-app-bus-01-diag"
      log_analytics_workspace_id = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/bus-la-weeu-p-central-01"
      storage_account_id         = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/busstrpcentralla0001"
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
    keyvault_id = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/bus-kv-weeu-s-sh-bus-01"
    secrets = [
      {
        name  = "epamuser"
        value = "My$ecureP@ss"
      }
    ]

  },
  {
    keyvault_id = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/bus-kv-weeu-s-app-bus-01"
    kv_name     = "bus-kv-weeu-s-app-bus-01"

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
            scope                = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/bus-kv-weeu-s-app-bus-01/secrets/secret"
          }
          principal_id = "7bca97c4-40de-41e3-a290-a3586a277841"
        }
      }
    ]
  }
]

storage_accounts = [
  {
    storage_name                    = "busstorvmsbsbus011"
    rg_name                         = "bus-rg-weeu-s-infra-01"
    location                        = "westeurope"
    account_tier                    = "Standard"
    account_kind                    = "StorageV2"
    account_replication_type        = "LRS"
    enable_https_traffic_only       = true
    min_tls_version                 = "TLS1_2"
    allow_nested_items_to_be_public = false
    blob_delete_retention_day       = 7
    access_tier                     = "Hot"
    is_hns_enabled                  = false
    large_file_share_enabled        = false
    network_rules = {
      bypass         = "AzureServices"
      default_action = "Deny"
      ip_rules       = []
      subnet_associations = [
        {
          subnet_name = "PrivateEndpointSubnet"
          vnet_name   = "bus-vnet-weeu-s-spoke-01"
          rg_name     = "bus-rg-weeu-s-network-01"
        }
      ]
      external_subnet_ids = []
    }
    diagnostic_setting = {
      name                       = "busstorvmsbsbus011-diag"
      storage_account_id         = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/busstrpcentralla0001"
      log_analytics_workspace_id = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/bus-la-weeu-p-central-01"
      metric                     = ["Capacity", "Transaction"]
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

privateendpoints = [
  {
    name                = "bus-pe-s-01"
    resource_group_name = "bus-rg-weeu-s-infra-01"
    location            = "westeurope"
    subnet_id           = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-network-01/providers/Microsoft.Network/virtualNetworks/bus-vnet-weeu-s-spoke-01/subnets/PrivateEndpointSubnet"
    private_service_connection = {
      private_connection_resource_id = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/busstorvmsbsbus011"
      is_manual_connection           = false
      subresource_names              = ["blob"]
    }
  }
]

vnet_peerings = [
  {
    name                         = "bus-peer-weeu-s-gat-01"
    virtual_network_name         = "bus-vnet-weeu-s-spoke-01"
    resource_group_name          = "bus-rg-weeu-s-network-01"
    remote_virtual_network_name  = "gat-vnet-weeu-s-hub-01"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
  }
]

vms = [
  {
    vm_name                          = "vmnbus01"
    vm_rg_name                       = "bus-rg-weeu-s-compute-01"
    vm_size                          = "Standard_B2s_v2" //"Standard_D2s_v3" is unabailable in westeurope
    vm_admin_username                = "epamuser"
    admin_secret_kv_name             = "bus-kv-weeu-s-sh-bus-01"
    admin_secret_kv_rg_name          = "bus-rg-weeu-s-infra-01"
    kv_name                          = "bus-kv-weeu-s-sh-bus-01"
    kv_rg_name                       = "bus-rg-weeu-s-infra-01"
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
        nic_vnet_name                   = "bus-vnet-weeu-s-spoke-01"
        nic_vnet_rg_name                = "bus-rg-weeu-s-network-01"
        nic_subnet_name                 = "sn-core-01"
        enable_ip_forwarding            = false
        enable_accelerated_networking   = true
        vm_private_ip_allocation_method = "Static"
        vm_private_ip_address           = "10.1.16.11"
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
