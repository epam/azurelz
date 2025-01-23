rg_list = [
  {
    name     = "gat-rg-weeu-s-network-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  },
  {
    name     = "gat-rg-weeu-s-infra-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  }
]

storage_accounts = [
  {
    storage_name = "gatstrphnetworkingla0001"
    rg_name      = "gat-rg-weeu-s-infra-01"
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
    name              = "gat-la-weeu-s-hubNetworking-01"
    rg_name           = "gat-rg-weeu-s-infra-01"
    location          = "westeurope"
    pricing_tier      = "PerGB2018"
    retention_in_days = 60
    activity_log_subs = ["914f2703-8449-43e5-aecf-9e013aeb7b2d"]
    diagnostic_setting = {
      name               = "gat-la-weeu-s-hubNetworking-01-dgs"
      storage_account_id = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/gatstrphnetworkingla0001"
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
    vnet_name     = "gat-vnet-weeu-s-hub-01"
    rg_name       = "gat-rg-weeu-s-network-01"
    location      = "westeurope"
    address_space = ["10.1.48.0/20"]
    subnets = [
      {
        name             = "GatewaySubnet"
        address_prefixes = ["10.1.56.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      },
      {
        name             = "PrivateEndpointSubnet"
        address_prefixes = ["10.1.57.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      },
      {
        name             = "AzureFirewallSubnet"
        address_prefixes = ["10.1.58.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      },
      {
        name             = "AzureBastionSubnet"
        address_prefixes = ["10.1.59.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      }
    ]
    diagnostic_setting = {
      name                       = "gat-vnet-weeu-s-hub-01-diag"
      log_analytics_workspace_id = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/gat-la-weeu-s-hubNetworking-01"
      storage_account_id         = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/gatstrphnetworkingla0001"
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
