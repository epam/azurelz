variable "name" {
  description = "Specifies the name of the Public IP resource . Changing this forces a new resource to be created."
  type        = string
}

variable "rg_name" {
  description = "The name of the Resource group"
  type        = string
}

variable "location" {
  description = <<EOF
    Specifies the supported Azure location where the resource exists.
    If the parameter is not specified in the configuration file, the location of the resource group is used.
  EOF
  type        = string
  default     = null
}

variable "allocation_method" {
  description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic."
  type        = string
  default     = "Static"
}

variable "sku" {
  description = "The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic."
  type        = string
  default     = "Standard"
}

variable "zones" {
  description = "A collection containing the availability zone to allocate the Public IP in"
  type        = list(string)
  default     = []
}

variable "ip_version" {
  description = "The IP Version to use, IPv6 or IPv4."
  type        = string
  default     = "IPv4"
}

variable "domain_name_label" {
  description = <<EOF
    Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public
    IP in the Microsoft Azure DNS system.
  EOF
  type        = string
  default     = null
}

variable "idle_timeout_in_minutes" {
  description = "Specifies the timeout for the TCP idle connection. The value can be set between 4 and 30 minutes."
  type        = number
  default     = 4
}

variable "reverse_fqdn" {
  description = <<EOF
    A fully qualified domain name that resolves to this public IP address. If the reverseFqdn is specified, then a PTR DNS record is
    created pointing from the IP address in the in-addr.arpa domain to the reverse FQDN.
  EOF
  type        = string
  default     = null
}

variable "diagnostic_setting" {
  description = <<EOF
  The description of parameters for Diagnostic Setting:
    `name` - specifies the name of the Diagnostic Setting;
    `log_analytics_workspace_id` - ID of the Log Analytics Workspace;
    `eventhub_name` - Specifies the name of the Event Hub where Diagnostics Data should be sent;
    `eventhub_authorization_rule_id` - Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data;
    `storage_account_id` - the ID of the Storage Account where logs should be sent;
    `log_category` - The list of Diagnostic Log Category's names for this Resource. list of available logs: `DDoSProtectionNotifications`, `DDoSMitigationFlowLogs`, `DDoSMitigationReports`;
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

variable "ddos_protection_mode" {
  description = <<EOF
    The DDoS protection mode of the public IP. Possible values are Disabled, Enabled, and VirtualNetworkInherited. Defaults to VirtualNetworkInherited.
  EOF
  type        = string
  default     = "VirtualNetworkInherited"
}

variable "ddos_protection_plan_id" {
  description = <<EOF
    The ID of DDoS protection plan associated with the public IP. Can only be set when ddos_protection_mode is Enabled
  EOF
  type        = string
  default     = null
}
