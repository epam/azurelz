variable "name" {
  description = <<EOT
  Specifies the name of the Log Analytics Workspace. Workspace name should include
  4-63 letters, digits or '-'.
  EOT 
  type        = string
}

variable "location" {
  description = <<EOT
  Specifies the supported Azure location where the resource exists.
  If the parameter is not specified in the configuration file, the location of the resource group is used.
  EOT
  type        = string
  default     = null
}

variable "rg_name" {
  description = "The name of the resource group in which the Log Analytics workspace is created."
  type        = string
}

variable "pricing_tier" {
  description = <<EOT
  Specifies the Sku of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard,
  Standalone, Unlimited, CapacityReservation, and PerGB2018 (new Sku as of 2018-04-03). Defaults to PerGB2018.
  EOT 
  type        = string
}

variable "retention_in_days" {
  description = <<EOT
  The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 
  30 and 730
  EOT 
  type        = number
  default     = null
}

variable "activity_log_subs" {
  description = <<EOT
  List of subscriptions ID for which you need to spice up the Activity log to this workspace, the user 
  running terraform needs at least Monitoring Contributor permissions on the target subscription
  EOT 
  type        = list(string)
  default     = []
}

variable "deployment_mode" {
  description = "The resource group template deployment mode"
  type        = string
  default     = "Incremental"
}

variable "la_solutions" {
  description = <<EOT
  The description of parameters for resource Log Analytics Solution.
  `la_sln_name`- Specifies the name of the solution to be deployed
  `la_sln_publisher` - The publisher of the solution. For example Microsoft. 
   Changing this forces a new resource to be created.
  `la_sln_product` - The product name of the solution. For example "OMSGallery/Containers".
   Changing this forces a new resource to be created.
   EOT
  type        = list(map(string))
  default     = []
}

variable "diagnostic_setting" {
  description = <<EOF
  The description of parameters for Diagnostic Setting:
    `name` - specifies the name of the Diagnostic Setting;
    `log_analytics_workspace_id` - ID of the Log Analytics Workspace;
    `eventhub_name` - Specifies the name of the Event Hub where Diagnostics Data should be sent;
    `eventhub_authorization_rule_id` - Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data;
    `storage_account_id` - the ID of the Storage Account where logs should be sent;
    `log_category` - The list of Diagnostic Log Category's names for this Resource. list of available logs: Audit;
    `log_category_group` - The list of Diagnostic Log Category's Group for this Resource. list of available logs: audit, allLogs;
    `metric` - The list of Diagnostic Metric Category's names for this Resource. List of available Metrics: AllMetrics;
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