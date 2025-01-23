variable "resource_group_name" {
  type        = string
  description = <<EOF
    The name of the resource group in which to create the Bastion Host.
    Changing this forces a new resource to be created.
  EOF
}

variable "subnet_id" {
  type        = string
  description = "The ID of subnet for AzureBastion, must be exactly 'AzureBastionSubnet' to be used for the Azure Bastion Host resource"
}

variable "location" {
  type        = string
  description = <<EOF
    Specifies the supported Azure location where the resource exists.
    If the parameter is not specified in the configuration file, the location of the resource group is used.
  EOF
  default     = null
}

variable "public_ip_address_id" {
  type        = string
  description = <<EOF
    Reference to a Public IP Address to associate with this Bastion Host. Changing this forces a new resource
    to be created.
  EOF
}

variable "bastion_host_name" {
  type        = string
  description = "The name of bastion host"
}

variable "diagnostic_setting" {
  description = <<EOF
  The description of parameters for Diagnostic Setting:
    `name` - specifies the name of the Diagnostic Setting;
    `log_analytics_workspace_id` - ID of the Log Analytics Workspace;
    `eventhub_name` - Specifies the name of the Event Hub where Diagnostics Data should be sent;
    `eventhub_authorization_rule_id` - Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data;
    `storage_account_id` - the ID of the Storage Account where logs should be sent;
    `log_category` - The list of Diagnostic Log Category's names for this Resource. list of available logs: `BastionAuditLogs`;
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

variable "sku" {
  type        = string
  default     = "Basic"
  description = "The SKU of the Bastion Host"
}

variable "scale_units" {
  type        = string
  default     = "2"
  description = "The number of scale units with which to provision the Bastion Host"
}

variable "tunneling_enabled" {
  type        = bool
  default     = false
  description = "Is Tunneling feature enabled for the Bastion Host"
}

variable "shareable_link_enabled" {
  type        = bool
  default     = false
  description = "Is Shareable Link feature enabled for the Bastion Host"
}

variable "ip_connect_enabled" {
  type        = bool
  default     = false
  description = "Is IP Connect feature enabled for the Bastion Host"
}

variable "copy_paste_enabled" {
  type        = bool
  default     = true
  description = "Is Copy/Paste feature enabled for the Bastion Host. Defaults to true."
}

variable "file_copy_enabled" {
  type        = bool
  default     = false
  description = "Is File Copy feature enabled for the Bastion Host"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
