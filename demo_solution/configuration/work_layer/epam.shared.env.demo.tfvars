tfstate_backend = {
  backend_tfstate_file_path =  "../base_layer/terraform.tfstate.d/epam.shared.env.demo/terraform.tfstate"

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

automation_accounts = [
  {
    automation_account_name = "sh-aa-weeu-p-patching-01"
    resource_group_name     = "sh-rg-weeu-s-infra-01"

    update_management = {
      workspace_rg_name = "sh-rg-weeu-s-infra-01"
      workspace_name    = "sh-la-weeu-p-centralShared-01"
    }

    diagnostic_setting = {
      name                       = "sh-aa-weeu-p-patching-01-diag"
      log_analytics_workspace_id = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/sh-la-weeu-p-centralShared-01"
      storage_account_id         = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/shstrpcsharedla0001"
      log_category               = ["JobLogs", "JobStreams", "DscNodeStatus", "AuditEvent"]
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

private_dns_zones = [
  {
    private_dns_zone_name    = "privatelink.vaultcore.azure.net"
    private_dns_zone_rg_name = "sh-rg-weeu-s-infra-01"
    vnet_list = [
      {
        virtual_network_id   = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-network-01/providers/Microsoft.Network/virtualNetworks/sh-vnet-weeu-s-spoke-01"
        registration_enabled = false
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
    name                            = "sh-kv-weeu-s-sh-sha-01"
    rg_name                         = "sh-rg-weeu-s-infra-01"
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
          vnet_name   = "sh-vnet-weeu-s-spoke-01"
          rg_name     = "sh-rg-weeu-s-network-01"
        }
      ]
    }
    rbac = [
      {
        principal_id = "7bca97c4-40de-41e3-a290-a3586a277841"
        assigment = {
          role_definition_name = "Key Vault Administrator"
          description          = "Assigment the KeyVault administrator role"
          scope                = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/sh-kv-weeu-s-sh-sha-01"
        }
      }
    ]
    diagnostic_setting = {
      name                       = "sh-kv-weeu-s-sh-sha-01-diag"
      log_analytics_workspace_id = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/sh-la-weeu-p-centralShared-01"
      storage_account_id         = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/shstrpcsharedla0001"
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
    name                            = "sh-kv-weeu-s-app-sha-01"
    rg_name                         = "sh-rg-weeu-s-infra-01"
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
          vnet_name   = "sh-vnet-weeu-s-spoke-01"
          rg_name     = "sh-rg-weeu-s-network-01"
        }
      ]
    }
    rbac = [
      {
        principal_id = "7bca97c4-40de-41e3-a290-a3586a277841"
        assigment = {
          role_definition_name = "Key Vault Administrator"
          description          = "Assigment the KeyVault administrator role"
          scope                = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/sh-kv-weeu-s-app-sha-01"
        }
      }
    ]
    diagnostic_setting = {
      name                       = "sh-kv-weeu-s-app-sha-01-diag"
      log_analytics_workspace_id = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/sh-la-weeu-p-centralShared-01"
      storage_account_id         = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/shstrpcsharedla0001"
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
    keyvault_id = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/sh-kv-weeu-s-sh-sha-01"
    secrets = [
      {
        name  = "epamuser"
        value = "My$ecureP@ss"
      }
    ]
  },
  {
    keyvault_id = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/sh-kv-weeu-s-app-sha-01"
    kv_name     = "bus-kv-weeu-s-app-sha-01"
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
            scope                = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/sh-kv-weeu-s-app-sha-01/secrets/secret"
          }
          principal_id = "7bca97c4-40de-41e3-a290-a3586a277841"
        }
      }
    ]
  }
]

vnet_peerings = [
  {
    name                         = "sh-peer-weeu-s-gat-01"
    virtual_network_name         = "sh-vnet-weeu-s-spoke-01"
    resource_group_name          = "sh-rg-weeu-s-network-01"
    remote_virtual_network_name  = "gat-vnet-weeu-s-hub-01"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
  }
]

route_tables = [
  {
    name                          = "sh-udr-weeu-s-fw"
    location                      = "westeurope"
    resource_group_name           = "sh-rg-weeu-s-network-01"
    disable_bgp_route_propagation = false
    routes = [
      {
        name                   = "udr-weeu-s-fw"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.1.58.4"
      }
    ]
    subnet_associate = [
      {
        subnet_id = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-network-01/providers/Microsoft.Network/virtualNetworks/sh-vnet-weeu-s-spoke-01/subnets/PrivateEndpointSubnet"
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

vms = [
  {
    vm_name                          = "vmnshared01"
    vm_rg_name                       = "sh-rg-weeu-s-compute-01"
    vm_size                          = "Standard_B2s_v2" //"Standard_D2s_v3" is unabailable in westeurope
    vm_admin_username                = "epamuser"
    admin_secret_kv_name             = "sh-kv-weeu-s-sh-sha-01"
    admin_secret_kv_rg_name          = "sh-rg-weeu-s-infra-01"
    kv_name                          = "sh-kv-weeu-s-sh-sha-01"
    kv_rg_name                       = "sh-rg-weeu-s-infra-01"
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
        nic_vnet_name                   = "sh-vnet-weeu-s-spoke-01"
        nic_vnet_rg_name                = "sh-rg-weeu-s-network-01"
        nic_subnet_name                 = "PrivateEndpointSubnet"
        enable_ip_forwarding            = false
        enable_accelerated_networking   = true
        vm_private_ip_allocation_method = "Static"
        vm_private_ip_address           = "10.1.34.11"
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
