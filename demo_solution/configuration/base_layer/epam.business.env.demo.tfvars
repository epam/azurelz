rg_list = [
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

storage_accounts = [
  {
    storage_name = "busstrpcentralla0001"
    rg_name      = "bus-rg-weeu-s-infra-01"
    location     = "westeurope"
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

logAnalytics = [
  {
    name              = "bus-la-weeu-p-central-01"
    rg_name           = "bus-rg-weeu-s-infra-01"
    pricing_tier      = "PerGB2018"
    retention_in_days = 60
    location          = "westeurope"
    activity_log_subs = ["ef5a88d0-c379-4883-af44-af9a5570cfa2"]
    diagnostic_setting = {
      name               = "bus-la-weeu-p-central-01-dgs"
      storage_account_id = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/busstrpcentralla0001"
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

vnets = [
  {
    vnet_name     = "bus-vnet-weeu-s-spoke-01"
    rg_name       = "bus-rg-weeu-s-network-01"
    location      = "westeurope"
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
      log_analytics_workspace_id = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/bus-la-weeu-p-central-01"
      storage_account_id         = "/subscriptions/ef5a88d0-c379-4883-af44-af9a5570cfa2/resourceGroups/bus-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/busstrpcentralla0001"
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
