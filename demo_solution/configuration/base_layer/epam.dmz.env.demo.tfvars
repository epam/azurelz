rg_list = [
  {
    name     = "dmz-rg-weeu-s-network-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  },
  {
    name     = "dmz-rg-weeu-s-infra-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  },
  {
    name     = "dmz-rg-weeu-s-compute-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  }
]

identity = [
  {
    identity_name = "dmz-demo-identity-01"
    location      = "westeurope"
    rg_name       = "dmz-rg-weeu-s-network-01"
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

storage_accounts = [
  {
    storage_name = "dmzstrpcnetworkingla0001"
    rg_name      = "dmz-rg-weeu-s-infra-01"
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
    name              = "dmz-la-weeu-p-centralnetworking-01"
    rg_name           = "dmz-rg-weeu-s-infra-01"
    location          = "westeurope"
    pricing_tier      = "PerGB2018"
    retention_in_days = 60
    activity_log_subs = ["a3339543-0d5d-4528-8efa-d51c0ecf0b55"]
    diagnostic_setting = {
      name               = "dmz-la-weeu-p-centralnetworking-01-dgs"
      storage_account_id = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/dmzstrpcnetworkingla0001"
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
    vnet_name     = "dmz-vnet-weeu-s-spoke-01"
    rg_name       = "dmz-rg-weeu-s-network-01"
    location      = "westeurope"
    address_space = ["10.1.80.0/20"]
    subnets = [
      {
        name             = "ApplicationGatewaySubnet"
        address_prefixes = ["10.1.80.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      },
      {
        name             = "sn-core-01"
        address_prefixes = ["10.1.81.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
          "Microsoft.Storage",
          "Microsoft.Sql",
          "Microsoft.AzureCosmosDB"
        ]
      }
    ]
    diagnostic_setting = {
      name                       = "dmz-vnet-weeu-s-spoke-01-diag"
      log_analytics_workspace_id = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/dmz-la-weeu-p-centralnetworking-01"
      storage_account_id         = "/subscriptions/a3339543-0d5d-4528-8efa-d51c0ecf0b55/resourceGroups/dmz-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/dmzstrpcnetworkingla0001"
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
