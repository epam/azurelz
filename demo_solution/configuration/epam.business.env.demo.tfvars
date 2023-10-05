# BASE layer
# 005_rg
rg_list = [
  # epam.business.env.demo
  {
    name     = "bus-rg-weeu-s-network-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  },
  {
    name     = "bus-rg-weeu-s-infra-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  },
  {
    name     = "bus-rg-weeu-s-compute-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  }
]

# 010_loganalytics
logAnalytics = [
  # epam.business.env.demo
  {
    name                            = "bus-la-weeu-p-central-01"
    rg_name                         = "bus-rg-weeu-s-infra-01"
    pricing_tier                    = "PerGB2018"
    retention_in_days               = 60
    storage_account_name            = "busstrpcentralla0001"
    assignment_role_definition_name = "Monitoring Contributor"
    assignment_description          = "Can read all monitoring data and update monitoring settings."
    # Please configure subscriptions "IDs"
    activity_log_subs                    = ["#{ENV_AZURE_SUBSCRIPTION_ID}#"]
    monitoring_contributor_assigment_ids = {}

    diagnostic_setting = {
      name = "bus-la-weeu-p-central-01-dgs"
      # uncomment if you want to use existing storage account to store logs
      # storage_account_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/<storage_name>"
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
  # epam.business.env.demo
  {
    vnet_name     = "bus-vnet-weeu-s-spoke-01"
    rg_name       = "bus-rg-weeu-s-network-01"
    address_space = ["10.1.16.0/20"]
    subnets = [
      {
        name             = "sn-core-01"
        address_prefixes = ["10.1.16.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      },
      {
        name             = "PrivateEndpointSubnet"
        address_prefixes = ["10.1.17.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      },
      {
        name             = "sn-core-02"
        address_prefixes = ["10.1.18.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      }
    ]
    diagnostic_setting = {
      name                       = "bus-vnet-weeu-s-spoke-01-diag"
      log_analytics_workspace_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/bus-la-weeu-p-central-01"
      storage_account_id         = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/busstrpcentralla0001"
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
# backend tfstate data from base layer
backend_tfstate_file_path_list = [
  "../base_layer/terraform.tfstate.d/epam.shared.env.demo",
  "../base_layer/terraform.tfstate.d/epam.identity.env.demo",
  "../base_layer/terraform.tfstate.d/epam.dmz.env.demo",
  "../base_layer/terraform.tfstate.d/epam.business.env.demo",
  "../base_layer/terraform.tfstate.d/epam.gateway.env.demo"
]

# 030_nsg
nsgs = [
  {
    name                = "demo-nsg-weeu-s-bs-vm"
    location            = "westeurope"
    resource_group_name = "bus-rg-weeu-s-network-01"
    subnet_associate = [
      {
        subnet_name = "sn-core-01"
        vnet_name   = "bus-vnet-weeu-s-spoke-01"
        rg_name     = "bus-rg-weeu-s-network-01"
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
      log_analytics_workspace_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/bus-la-weeu-p-central-01"
      storage_account_id         = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/busstrpcentralla0001"
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

# 035_keyvault
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
          vnet_name   = "bus-vnet-weeu-s-spoke-01"
          rg_name     = "bus-rg-weeu-s-network-01"
        }
      ]
    }
    diagnostic_setting = {
      name                       = "bus-kv-weeu-s-sh-bus-01-giag"
      log_analytics_workspace_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/bus-la-weeu-p-central-01"
      storage_account_id         = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/busstrpcentralla0001"
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
        principal_id = "#{ENV_AZURE_SP_OBJECT_ID}#"
        assigment = {
          role_definition_name = "Key Vault Administrator"
          description          = "Assigment the KeyVault administrator role"
          scope                = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/bus-kv-weeu-s-app-bus-01"
        }
      }
    ]

    diagnostic_setting = {
      name                       = "bus-kv-weeu-s-app-bus-01-diag"
      log_analytics_workspace_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/bus-la-weeu-p-central-01"
      storage_account_id         = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/busstrpcentralla0001"
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
    keyvault_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/bus-kv-weeu-s-sh-bus-01"

    secrets = [
      {
        name  = "epamuser"
        value = "My$ecureP@ss"
      }
    ]

  },
  {
    keyvault_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/bus-kv-weeu-s-app-bus-01"
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
            scope                = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.KeyVault/vaults/bus-kv-weeu-s-app-bus-01/secrets/secret"
          }
          principal_id = "#{ENV_AZURE_SP_OBJECT_ID}#"
        }
      }
    ]
  }
]

# 035_storageaccount
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

    private_endpoint = {
      name                = "bus-pe-s-01"
      resource_group_name = "bus-rg-weeu-s-infra-01"
      location            = "westeurope"
      subresource_names   = ["blob"]
      subnet = {
        name      = "PrivateEndpointSubnet"
        vnet_name = "bus-vnet-weeu-s-spoke-01"
        vnet_rg   = "bus-rg-weeu-s-network-01"
      }
    }

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
      storage_account_id         = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/busstrpcentralla0001"
      log_analytics_workspace_id = "/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/bus-la-weeu-p-central-01"
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

# 035_vnetpeering

vnet_peerings = [
  # epam.business.env.demo
  {
    name                         = "bus-peer-weeu-s-gat-01"
    source_vnet_name             = "bus-vnet-weeu-s-spoke-01"
    source_vnet_rg_name          = "bus-rg-weeu-s-network-01"
    destination_vnet_name        = "gat-vnet-weeu-s-hub-01"
    destination_vnet_rg_name     = "gat-rg-weeu-s-network-01"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
  }
]

# 060_vm
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
