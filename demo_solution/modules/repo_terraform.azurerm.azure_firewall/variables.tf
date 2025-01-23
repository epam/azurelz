variable "name" {
  description = "Specifies the name of the Firewall."
  type        = string
}

variable "location" {
  description = <<EOF
  Specifies the supported Azure location where the resource exists.
  If not specified - RG location will be used.
  EOF
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resource."
  type        = string
}

variable "public_ip_address_id" {
  description = "The Id of mapped public IP"
  type        = string
}

variable "firewall_policy_name" {
  description = "Name of the firewall policy which will be assigned to the firewall."
  type        = string
  default     = null
}

variable "firewall_policy_rg_name" {
  description = <<EOF
  Name of the resource group of the firewall policy which will be assigned to the
  firewall.
  EOF
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "Sku tier of the Firewall. Possible values are Premium and Standard."
  type        = string
  default     = "Standard"
}

variable "sku_name" {
  description = "Sku name of the Firewall. Possible values are AZFW_Hub and AZFW_VNet."
  type        = string
  default     = "AZFW_VNet"
}

variable "subnet_id" {
  type        = string
  description = "The ID of subnet for AzureFirewall, must be exactly 'AzureFirewallSubnet' to be used for the Azure Bastion Host resource"
}

variable "zones" {
  description = "Specifies the availability zones in which the Azure Firewall should be created."
  type        = list(string)
  default     = null
}

variable "dns_servers" {
  description = "A list of DNS servers that the Azure Firewall will direct DNS traffic to the for name resolution."
  type        = list(string)
  default     = null
}

variable "dns_proxy_enabled" {
  description = <<EOF
  Whether DNS proxy is enabled. It will forward DNS requests to the DNS servers when set to true.
  It will be set to true if dns_servers provided with a not empty list.
  DNS parameters (Network.DNS.Servers,Network.DNS.EnableProxy) under additional properties are not allowed for firewall
  deployed in virtual hub or vnet firewall attached to a firewall policy. DNS configuration should be managed by policy.
  EOF
  type        = bool
  default     = false
}

variable "management_ip_configuration" {
  description = <<EOF
  Allows force-tunnelling of traffic to be performed by the firewall. Adding or removing this
  block or changing the subnet_id in an existing block forces a new resource to be created.
  EOF
  type        = list(map(string))
  default     = []
}

variable "netw_rule_collections" {
  description = <<EOF
  Collection contains priority, action, source addresses, destination addresses,
  destination ports, protocols.
  EOF
  type = list(object({
    name     = string
    priority = number
    action   = string
    rule = list(object({
      name                  = string
      description           = string
      source_addresses      = list(string)
      source_ip_groups      = list(string)
      destination_addresses = list(string)
      destination_ip_groups = list(string)
      destination_fqdns     = list(string)
      destination_ports     = list(string)
      protocols             = list(string)
    }))
  }))
  default = []
}

variable "diagnostic_setting" {
  description = <<EOF
  The description of parameters for Diagnostic Setting:
    `name` - specifies the name of the Diagnostic Setting;
    `log_analytics_workspace_id` - ID of the Log Analytics Workspace;
    `eventhub_name` - Specifies the name of the Event Hub where Diagnostics Data should be sent;
    `eventhub_authorization_rule_id` - Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data;
    `storage_account_id` - the ID of the Storage Account where logs should be sent;
    `log_category` - The list of Diagnostic Log Category's names for this Resource. list of available logs: 
        _AzureFirewallApplicationRule_ - each new connection that matches one of your configured application
       rules results in a log for the accepted/denied connection;
        _AzureFirewallNetworkRule_ - each new connection that matches one of your configured network rules
       results in a log for the accepted/denied connection;
        _AzureFirewallDnsProxy_ - this log tracks DNS messages to a DNS server configured using DNS proxy;
        _AZFWNetworkRule_ - contains all Network Rule log data. Each match between data plane and network rule creates 
      a log entry with the data plane packet and the matched rule's attributes;
        _AZFWApplicationRule_ - Contains all Application rule log data. Each match between data plane and Application 
      rule creates a log entry with the data plane packet and the matched rule's attributes;
        _AZFWNatRule_ - contains all DNAT (Destination Network Address Translation) events log data. Each match
       between data plane and DNAT rule creates a log entry with the data plane packet and the matched rule's attributes;
        _AZFWThreatIntel_ - contains all Threat Intelligence events;
        _AZFWIdpsSignature_ - contains all data plane packets that were matched with one or more IDPS signatures;
        _AZFWDnsQuery_ - contains all DNS Proxy events log data;
        _AZFWFqdnResolveFailure_ - contains all internal Firewall FQDN resolution requests that resulted in failure;
        _AZFWFatFlow_ - this query returns the top flows across Azure Firewall instances. Log contains flow 
      information, date transmission rate (in Megabits per second units) and the time period when the flows were recorded;
        _AZFWFlowTrace_ - flow logs across Azure Firewall instances. Log contains flow information, flags and the time 
      period when the flows were recorded;
        _AZFWApplicationRuleAggregation_ - contains aggregated Application rule log data for Policy Analytics;
        _AZFWNetworkRuleAggregation_ - contains aggregated Network rule log data for Policy Analytics;
        _AZFWNatRuleAggregation_ - contains aggregated NAT Rule log data for Policy Analytics.
    `log_category_group` - The list of Diagnostic Log Category's Group for this Resource. list of available logs: `audit`, `allLogs`;
    `metric` - The list of Diagnostic Metric Category's names for this Resource. List of available Metrics: `AllMetrics`;
  EOF
  type = object({
    name                           = string
    log_analytics_workspace_id     = optional(string)
    storage_account_id             = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    log_category                   = optional(list(string))
    log_category_group             = optional(list(string))
    metric                         = optional(list(string))
  })
  validation {
    condition     = try(var.diagnostic_setting.log_category, null) == null || try(var.diagnostic_setting.log_category_group, null) == null
    error_message = "Diagnostic setting does not support mix of log category and log category group."
  }
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}