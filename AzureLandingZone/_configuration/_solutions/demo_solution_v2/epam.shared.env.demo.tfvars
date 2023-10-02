# BASE layer
# 005_rg
rg_list = [
  # epam.shared.env.demo
  {
    name     = "sh-rg-weeu-s-network-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  },
  {
    name     = "sh-rg-weeu-s-infra-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  },
  {
    name     = "sh-rg-weeu-s-compute-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  }
]

# 010_loganalytics
logAnalytics = [
  # epam.shared.env.demo
  {
    name                                 = "sh-la-weeu-p-centralShared-01"
    rg_name                              = "sh-rg-weeu-s-infra-01"
    pricing_tier                         = "PerGB2018"
    retention_in_days                    = 60
    storage_account_name                 = "shstrpcsharedla0001"
    assignment_role_definition_name      = "Monitoring Contributor"
    assignment_description               = "Can read all monitoring data and update monitoring settings."
    monitoring_contributor_assigment_ids = {}
    # Please configure subscriptions "IDs"
    activity_log_subs = ["#{ENV_AZURE_SUBSCRIPTION_ID}#"]
    diagnostic_setting = {
      name = "sh-la-weeu-p-centralShared-01-dgs"
      # storage_account_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/<storage_name>"
      log_category_group = ["audit"]
      metric             = ["AllMetrics"]
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

# 025_vnet
vnets = [
  # epam.shared.env.demo
  {
    vnet_name     = "sh-vnet-weeu-s-spoke-01"
    rg_name       = "sh-rg-weeu-s-network-01"
    address_space = ["10.1.32.0/20"]
    subnets = [
      {
        name             = "sn-core-01"
        address_prefixes = ["10.1.32.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      },
      {
        name             = "PrivateEndpointSubnet"
        address_prefixes = ["10.1.34.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      },
      {
        name             = "sn-core-02"
        address_prefixes = ["10.1.35.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      },
      {
        name             = "sn-core-03"
        address_prefixes = ["10.1.36.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      },
      {
        name             = "sn-core-04"
        address_prefixes = ["10.1.33.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      }
    ]
    diagnostic_setting = {
      name                       = "sh-vnet-weeu-s-spoke-01-diag"
      log_analytics_workspace_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/sh-la-weeu-p-centralShared-01"
      storage_account_id         = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/shstrpcsharedla0001"
      log_category               = ["VMProtectionAlerts"]
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


# WORK layer
backend_tfstate_file_path = "../base_layer/terraform.tfstate.d/epam.shared.env.demo"
backend_tfstate_file_path_list = [
  "../base_layer/terraform.tfstate.d/epam.shared.env.demo",
  "../base_layer/terraform.tfstate.d/epam.identity.env.demo",
  "../base_layer/terraform.tfstate.d/epam.dmz.env.demo",
  "../base_layer/terraform.tfstate.d/epam.business.env.demo",
  "../base_layer/terraform.tfstate.d/epam.gateway.env.demo"
]

# 020_automationaccount
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
      log_analytics_workspace_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/sh-la-weeu-p-centralShared-01"
      storage_account_id         = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/shstrpcsharedla0001"
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

# 030_privatedns
private_dns_zones = [
  {
    private_dns_zone_name    = "privatelink.vaultcore.azure.net"
    private_dns_zone_rg_name = "sh-rg-weeu-s-infra-01"
    vnet_list = [
      {
        virtual_network_id   = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-network-01/providers/Microsoft.Network/virtualNetworks/sh-vnet-weeu-s-spoke-01"
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

# 035_keyvault
keyvaults = [
  {
    name                            = "sh-kv-weeu-s-sh-shared-01"
    rg_name                         = "sh-rg-weeu-s-infra-01"
    sku                             = "standard"
    soft_delete_retention_days      = "90"
    enabled_for_deployment          = true
    enabled_for_disk_encryption     = true
    enabled_for_template_deployment = true
    purge_protection_enabled        = false
    enable_rbac_authorization       = false

    access_policies = [
      {
        object_ids              = ["#{ENV_AZURE_SP_OBJECT_ID}#"]
        secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
        certificate_permissions = ["Get", "Create", "List", "Import", "Purge", "Delete"]
        key_permissions         = ["Get", "Create", "List", "Delete", "Purge"]
      }
    ]

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

    diagnostic_setting = {
      name                       = "sh-kv-weeu-s-sh-shared-01-diag"
      log_analytics_workspace_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/sh-la-weeu-p-centralShared-01"
      storage_account_id         = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/shstrpcsharedla0001"
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
    name                            = "sh-kv-weeu-s-app-shared-01"
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
        principal_id = "#{ENV_AZURE_SP_OBJECT_ID}#"
        assigment = {
          role_definition_name = "Key Vault Administrator"
          description          = "Assigment the KeyVault administrator role"
          scope                = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/sh-kv-weeu-s-app-shared-01"
        }
      }
    ]

    diagnostic_setting = {
      name                       = "sh-kv-weeu-s-app-shared-01-diag"
      log_analytics_workspace_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/sh-la-weeu-p-centralShared-01"
      storage_account_id         = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/shstrpcsharedla0001"
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

# 035_keyvaultcontent
keyvaultcontents = [
  {
    keyvault_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/sh-kv-weeu-s-sh-shared-01"

    secrets = [
      {
        name  = "epamuser"
        value = "My$ecureP@ss"
      }
    ]

  },
  {
    keyvault_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/sh-kv-weeu-s-app-shared-01"
    kv_name     = "bus-kv-weeu-s-app-shared-01"

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
            scope                = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/sh-kv-weeu-s-app-shared-01/secrets/secret"
          }
          principal_id = "#{ENV_AZURE_SP_OBJECT_ID}#"
        }
      }
    ]
  }
]

# 035_vnetpeering
vnet_peerings = [
  # epam.shared.env.demo
  {
    name                         = "sh-peer-weeu-s-gat-01"
    source_vnet_name             = "sh-vnet-weeu-s-spoke-01"
    source_vnet_rg_name          = "sh-rg-weeu-s-network-01"
    destination_vnet_name        = "gat-vnet-weeu-s-hub-01"
    destination_vnet_rg_name     = "gat-rg-weeu-s-network-01"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
  }
]

# 050_udr
route_tables = [
  {
    name              = "sh-udr-weeu-s-fw"
    location          = "westeurope"
    rg_name           = "sh-rg-weeu-s-network-01"
    route_propogation = "no"
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
        subnet_name = "PrivateEndpointSubnet"
        vnet_name   = "sh-vnet-weeu-s-spoke-01"
        rg_name     = "sh-rg-weeu-s-network-01"
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

# 060_vm
vms = [
  {
    vm_name                          = "vmnshared01"
    vm_rg_name                       = "sh-rg-weeu-s-compute-01"
    vm_size                          = "Standard_B2s_v2" //"Standard_D2s_v3" is unabailable in westeurope
    vm_admin_username                = "epamuser"
    admin_secret_kv_name             = "sh-kv-weeu-s-sh-shared-01"
    admin_secret_kv_rg_name          = "sh-rg-weeu-s-infra-01"
    kv_name                          = "sh-kv-weeu-s-sh-shared-01"
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
