variable "automation_account_name" {
  description = " Specifies the name of the Automation Account."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the Automation Account is created."
  type        = string
}

variable "sku" {
  description = "The SKU of the account - only Basic is supported at this time."
  type        = string
  default     = "Basic"

}

variable "location" {
  description = <<EOF
  Specifies the supported Azure location where the resource exists.
  If the parameter is not specified in the configuration file, the location of the resource group is used.
  EOF
  type        = string
  default     = null
}

variable "identity_type" {
  description = <<EOF
  The type of identity used for the automation account. Possible values are `SystemAssigned`,
    `UserAssigned` and `SystemAssigned, UserAssigned`
  EOF
  type        = string
  default     = null
}

variable "identity_ids" {
  description = <<EOF
  The ID of the User Assigned Identity which should be assigned to this Automation Account. 
   `identity_ids` is required when type is set to `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`
  EOF
  type        = list(string)
  default     = []
}

variable "runbook" {
  description = <<EOF
  A list of maps which contains runbook parameters
    `runbook_name` - Specifies the name of the Runbook. Changing this forces a new resource to be created.
    `log_verbose` -  Verbose log option.
    `log_progress` - Progress log option.
    `runbook_type` - The type of the runbook - can be either "Graph", "GraphPowerShell", 
    "GraphPowerShellWorkflow", "PowerShellWorkflow", "PowerShell", "Python3", "Python2" or "Script".
    `script_file_name` - The name of file with script.
    `uri` - The URI of the runbook content.
  EOF
  type = list(object({
    runbook_name     = string
    log_verbose      = bool
    log_progress     = bool
    runbook_type     = string
    script_file_name = string
    uri              = string
  }))
  default = []
}

variable "schedule" {
  description = <<EOF
  A list of maps which contains schedule parameters
    `schedule_name`- Specifies the name of the Schedule. Changing this forces a new resource to be created.
    `frequency` - The frequency of the schedule. - can be either "OneTime", "Day", "Hour", "Week", or "Month".
    `interval` - The number of frequencys between runs. Only valid when frequency is "Day", "Hour", "Week", 
    or "Month" and defaults to 1.
    `description`- A description for this Schedule.
    `start_time` -  Start time of the schedule. Must be at least five minutes in the future. 
    Defaults to seven minutes in the future from the time the resource is created.
    `timezone` - The timezone of the start time. Defaults to UTC
    `week_days` -  List of days of the week that the job should execute on. Only valid when frequency is Week.
    `month_days` - List of days of the month that the job should execute on. Must be between 1 and 31. -1 for 
    last day of the month. Only valid when frequency is Month.
    `monthly_occurrence` - List of occurrences of days within a month. Only valid when frequency is Month. 
    The monthly_occurrence block supports fields documented below.
      - `day` - Day of the occurrence. Must be one of Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday.
      - `occurrence` - Occurrence of the week within the month. Must be between 1 and 5. -1 for last 
          week within the month.
  EOF
  type = list(object({
    schedule_name      = string
    frequency          = string
    interval           = string
    description        = string
    start_time         = string
    timezone           = string
    week_days          = list(any)
    month_days         = list(any)
    monthly_occurrence = map(string)
  }))
  default = []
}

variable "job_schedule" {
  description = <<EOF
  A list of maps which contains schedule parameters
    `runbook_name` - The name of a Runbook to link to a Schedule. It needs to be in the same Automation Account as 
    the Schedule and Job Schedule. Changing this forces a new resource to be created.
    `schedule_name` - The name of the Schedule. Changing this forces a new resource to be created.
    `A map of key/value pairs corresponding to the arguments that can be passed to the Runbook. 
    `parameters` - Changing this forces a new resource to be created.`
  EOF
  type = list(object({
    runbook_name  = string
    schedule_name = string
    parameters    = map(any)
  }))
  default = []
}

variable "module" {
  description = <<EOF
  A list of maps which contains module parameters
    `module_name` - Specifies the name of the Module. Changing this forces a new resource to be created.
    `module_link` - The published Module link.
      - `uri` - The URI of the module content (zip or nupkg).
  EOF
  type = list(object({
    module_name = string
    module_link = map(string)
  }))
  default = []
}

variable "webhook" {
  description = <<EOF
  A list of maps which contains webhook parameters
    `webhook_name` - Specifies the name of the Webhook. Changing this forces a new resource to be created.
    `expiry_time` - Timestamp when the webhook expires. Changing this forces a new resource to be created.
    `enabled` - Controls if Webhook is enabled. 
    `runbook_name` - Name of the Automation Runbook to execute by Webhook.
    `run_on_worker_group` - Name of the hybrid worker group the Webhook job will run on.
    `parameters` - Map of input parameters passed to runbook.
    `uri` - URI to initiate the webhook. Can be generated using Generate URI API. By default, new 
   URI is generated on each new resource creation. Changing this forces a new resource to be created.
  EOF
  type = list(object({
    webhook_name        = string
    expiry_time         = string
    enabled             = bool
    runbook_name        = string
    run_on_worker_group = string
    uri                 = string
    parameters          = list(any)
  }))
  default = []
}

variable "update_management" {
  description = <<EOF
If this parameter is not null, `Update Management` will be created
Parameters for getting Log Analytics ID
  `workspace_rg_name` - Specifies the name of the Log Analytics Workspace
  `workspace_name` - he name of the resource group in which the Log Analytics workspace is located in
EOF
  type        = map(string)
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
    `log_category` - The list of Diagnostic Log Category's names for this Resource. list of available logs: `JobLogs`, `JobStreams`, `DscNodeStatus`, `AuditEvent`;
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