rg_list = [
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

storage_accounts = [
  {
    storage_name = "shstrpcsharedla0001"
    rg_name      = "sh-rg-weeu-s-infra-01"
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
    name              = "sh-la-weeu-p-centralShared-01"
    rg_name           = "sh-rg-weeu-s-infra-01"
    location          = "westeurope"
    pricing_tier      = "PerGB2018"
    retention_in_days = 60
    activity_log_subs = ["f2d25c9a-5ccd-473f-8757-cea375294b4a"]
    diagnostic_setting = {
      name               = "sh-la-weeu-p-centralShared-01-dgs"
      storage_account_id = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/shstrpcsharedla0001"
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
    vnet_name     = "sh-vnet-weeu-s-spoke-01"
    rg_name       = "sh-rg-weeu-s-network-01"
    location      = "westeurope"
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
      log_analytics_workspace_id = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/sh-la-weeu-p-centralShared-01"
      storage_account_id         = "/subscriptions/f2d25c9a-5ccd-473f-8757-cea375294b4a/resourceGroups/sh-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/shstrpcsharedla0001"
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
