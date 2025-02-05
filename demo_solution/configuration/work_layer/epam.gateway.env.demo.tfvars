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
    automation_account_name = "gat-aa-weeu-p-patching-01"
    resource_group_name     = "gat-rg-weeu-s-infra-01"

    schedule = [
      {
        schedule_name      = "gat-schedule-weeu-s-01"
        frequency          = "Hour"
        interval           = null
        description        = null
        start_time         = null
        timezone           = null
        week_days          = null
        month_days         = null
        monthly_occurrence = null
      }
    ]

    job_schedule = [
      {
        schedule_name = "gat-schedule-weeu-s-01"
        runbook_name  = "gat-runbook-weeu-s-01"
        parameters    = {}
      }
    ]

    runbook = [
      {
        runbook_name     = "gat-runbook-weeu-s-01"
        runbook_type     = "PowerShell"
        log_verbose      = true
        log_progress     = true
        runbook_type     = "PowerShell"
        script_file_name = "runbook-fw.ps1"
        uri              = null
      }
    ]

    diagnostic_setting = {
      name                       = "gat-aa-weeu-p-patching-01-diag"
      log_analytics_workspace_id = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/gat-la-weeu-s-hubNetworking-01"
      storage_account_id         = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/gatstrphnetworkingla0001"
      log_category               = ["JobLogs", "JobStreams", "DscNodeStatus", "AuditEvent"]
      metric                     = ["AllMetrics"]
    }

    tags = {
      environment = ""
    }
  }
]

public_ips = [
  {
    name              = "gat-pip-weeu-s-hubnetfw-01"
    rg_name           = "gat-rg-weeu-s-network-01"
    allocation_method = "Static"
    sku               = "Standard"
    zones             = ["1", "2", "3"]
    ip_version        = "IPv4"
    domain_name_label = "gat-pip-weeu-gaw-hubnetfw-011"

    diagnostic_setting = {
      name                       = "gat-pip-weeu-s-hubnetfw-01-diag"
      log_analytics_workspace_id = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/gat-la-weeu-s-hubNetworking-01"
      storage_account_id         = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/gatstrphnetworkingla0001"
      log_category               = ["DDoSProtectionNotifications", "DDoSMitigationFlowLogs", "DDoSMitigationReports"]
      metric                     = ["AllMetrics"]
    }

    tags = {
      environment         = ""
      businessCriticality = ""
      businessUnit        = ""
      businessOwner       = ""
      platformSupport     = ""
      functionalSupport   = ""
      reviewedOn          = ""
    }
  },
  {
    name              = "gat-pip-weeu-s-vpngtw-01"
    rg_name           = "gat-rg-weeu-s-network-01"
    allocation_method = "Static"
    sku               = "Standard"
    zones             = ["1", "2", "3"]
    ip_version        = "IPv4"
    domain_name_label = "gat-pip-weeu-gaw-vpngtw-011"

    diagnostic_setting = {
      name                       = "gat-pip-weeu-s-vpngtw-01-diag"
      log_analytics_workspace_id = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/gat-la-weeu-s-hubNetworking-01"
      storage_account_id         = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/gatstrphnetworkingla0001"
      log_category               = ["DDoSProtectionNotifications", "DDoSMitigationFlowLogs", "DDoSMitigationReports"]
      metric                     = ["AllMetrics"]
    }

    tags = {
      environment         = ""
      businessCriticality = ""
      businessUnit        = ""
      businessOwner       = ""
      platformSupport     = ""
      functionalSupport   = ""
      reviewedOn          = ""
    }
  },
  {
    name              = "gat-pip-weeu-s-bstn-01"
    rg_name           = "gat-rg-weeu-s-network-01"
    allocation_method = "Static"
    sku               = "Standard"
    zones             = ["1", "2", "3"]
    ip_version        = "IPv4"
    domain_name_label = "gat-pip-weeu-gaw-bstn-011"

    diagnostic_setting = {
      name                       = "gat-pip-weeu-s-bstn-01-diag"
      log_analytics_workspace_id = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/gat-la-weeu-s-hubNetworking-01"
      storage_account_id         = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/gatstrphnetworkingla0001"
      log_category               = ["DDoSProtectionNotifications", "DDoSMitigationFlowLogs", "DDoSMitigationReports"]
      metric                     = ["AllMetrics"]
    }

    tags = {
      environment         = ""
      businessCriticality = ""
      businessUnit        = ""
      businessOwner       = ""
      platformSupport     = ""
      functionalSupport   = ""
      reviewedOn          = ""
    }
  }
]

virtual_gateways = [
  {
    name       = "gat-vgtw-weeu-s-vpn-shared-01"
    location   = "westeurope"
    rg_name    = "gat-rg-weeu-s-network-01"
    type       = "Vpn"
    sku        = "VpnGw2AZ"
    generation = "Generation1"
    ip_configuration = [
      {
        subnet_id            = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-network-01/providers/Microsoft.Network/virtualNetworks/gat-vnet-weeu-s-hub-01/subnets/GatewaySubnet"
        public_ip_address_id = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-network-01/providers/Microsoft.Network/publicIPAddresses/gat-pip-weeu-s-vpngtw-01"
      }
    ]

    local_network_gateway = {
      name            = "gat-vnet-weeu-s-hubnet-01-localgw"
      gateway_address = "1.1.1.1"
      address_space   = ["10.0.0.0/8"]
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

vnet_peerings = [
  {
    name                         = "gat-peer-weeu-s-dmz-01"
    virtual_network_name         = "gat-vnet-weeu-s-hub-01"
    resource_group_name          = "gat-rg-weeu-s-network-01"
    remote_virtual_network_name  = "dmz-vnet-weeu-s-spoke-01"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
  },
  {
    name                         = "gat-peer-weeu-s-sh-01"
    virtual_network_name         = "gat-vnet-weeu-s-hub-01"
    resource_group_name          = "gat-rg-weeu-s-network-01"
    remote_virtual_network_name  = "sh-vnet-weeu-s-spoke-01"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
  },
  {
    name                         = "gat-peer-weeu-s-bus-01"
    virtual_network_name         = "gat-vnet-weeu-s-hub-01"
    resource_group_name          = "gat-rg-weeu-s-network-01"
    remote_virtual_network_name  = "bus-vnet-weeu-s-spoke-01"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
  },
  {
    name                         = "gat-peer-weeu-s-idth-01"
    virtual_network_name         = "gat-vnet-weeu-s-hub-01"
    resource_group_name          = "gat-rg-weeu-s-network-01"
    remote_virtual_network_name  = "idth-vnet-weeu-s-spoke-01"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
  }
]

azure_firewalls = [
  {
    name                 = "gat-azfrw-weeu-s-hubnetfirewall"
    location             = "westeurope"
    resource_group_name  = "gat-rg-weeu-s-network-01"
    public_ip_address_id = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-network-01/providers/Microsoft.Network/publicIPAddresses/gat-pip-weeu-s-hubnetfw-01"
    subnet_id            = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-network-01/providers/Microsoft.Network/virtualNetworks/gat-vnet-weeu-s-hub-01/subnets/AzureFirewallSubnet"
    sku_tier             = "Premium"
    sku_name             = "AZFW_VNet"
    zones = [
      "1",
      "2",
      "3"
    ]
    netw_rule_collections = [
      {
        name     = "demo-test-rule"
        priority = 500
        action   = "Allow"
        rule = [
          {
            name                  = "demo-test-rule"
            description           = "first description"
            source_addresses      = ["10.1.34.0/24"]
            source_ip_groups      = null
            destination_addresses = ["*"]
            destination_ip_groups = null
            destination_fqdns     = null
            destination_ports     = ["8080"]
            protocols             = ["Any"]
          }
        ]
      }
    ]
    diagnostic_setting = {
      name                       = "gat-azfrw-weeu-s-hubnetfirewall-diag"
      log_analytics_workspace_id = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/gat-la-weeu-s-hubNetworking-01"
      storage_account_id         = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/gatstrphnetworkingla0001"
      log_category               = ["AzureFirewallApplicationRule", "AzureFirewallNetworkRule", "AzureFirewallDnsProxy", "AZFWNetworkRule", "AZFWApplicationRule", "AZFWNatRule", "AZFWThreatIntel", "AZFWIdpsSignature", "AZFWDnsQuery", "AZFWFqdnResolveFailure", "AZFWFatFlow", "AZFWFlowTrace", "AZFWApplicationRuleAggregation", "AZFWNetworkRuleAggregation", "AZFWNatRuleAggregation"]
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

bastion_host = [
  {
    resource_group_name    = "gat-rg-weeu-s-network-01"
    subnet_id              = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-network-01/providers/Microsoft.Network/virtualNetworks/gat-vnet-weeu-s-hub-01/subnets/AzureBastionSubnet"
    public_ip_address_id   = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-network-01/providers/Microsoft.Network/publicIPAddresses/gat-pip-weeu-s-bstn-01"
    bastion_host_name      = "gat-weeu-s-networking-shared-01-bastion"
    sku                    = "Standard"
    scale_units            = "2"
    tunneling_enabled      = true
    shareable_link_enabled = true
    ip_connect_enabled     = true
    file_copy_enabled      = true
    diagnostic_setting = {
      name                       = "conh-rg-weeu-p-network-01-diag"
      log_analytics_workspace_id = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/gat-la-weeu-s-hubNetworking-01"
      storage_account_id         = "/subscriptions/914f2703-8449-43e5-aecf-9e013aeb7b2d/resourceGroups/gat-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/gatstrphnetworkingla0001"
      log_category               = ["BastionAuditLogs"]
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
