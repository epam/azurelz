variable "name" {
  type        = string
  description = "The name of the Key Vault."
}

variable "resource_group_name" {
  type        = string
  description = "The name of an existing resource group for the Key Vault."
}

variable "location" {
  description = <<EOT
  Specifies the supported Azure location where the resource exists.
  If the parameter is not specified in the configuration file, the location of the resource group is used.
  EOT
  type        = string
  default     = null
}

variable "sku" {
  type        = string
  description = "The name of the SKU used for the Key Vault. The options are: `standard`, `premium`."
  default     = "standard"
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Allow Virtual Machines to retrieve certificates stored as secrets from the key vault."
  default     = false
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Allow Disk Encryption to retrieve secrets from the vault and unwrap keys."
  default     = false
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Allow Resource Manager to retrieve secrets from the key vault."
  default     = false
}

variable "access_policies" {
  description = <<EOF
  List of access policies for the Key Vault. May consist of:
  `object_ids` - List of object IDs, it can contain the id of a group, user, or service principal;
  `group_names` -List of the names of the groups;
  `user_principal_names` - List of user pricipal names;
  `application_names` - List of applications names;
  `storage_permissions` - List of storage permissions;
  `secret_permissions` - List of permissions for secret management operations. May contain values: 
                        `Get`, `List`, `Set`, `Delete`,`Recover`, `Backup`, `Restore`, `Purge`
  `certificate_permissions` -  List of certificate permissions, must be one or more from the following:
                              `Backup`, `Create`, `Delete`, `DeleteIssuers`, `Get`, `GetIssuers`, `Import`, `List`, `ListIssuers`,
                              `ManageContacts`, `ManageIssuers`, `Purge`, `Recover`, `Restore`, `SetIssuers` and `Update`
  `key_permissions` - List of key permissions, must be one or more from the following: `Backup`, 
                      `Create`, `Decrypt`, `Delete`, `Encrypt`, `Get`, `Import`, `List`, `Purge`, `Recover`, `Restore`,
                      `Sign`, `UnwrapKey`, `Update`, `Verify`, `WrapKey`, `Release`, `Rotate`, `GetRotationPolicy`,
                      and `SetRotationPolicy`
  `storage_permissions` - List of storage permissions, must be one or more from the following: `Backup`,
                          `Delete`, `DeleteSAS`, `Get`, `GetSAS`, `List`, `ListSAS`, `Purge`, `Recover`, `RegenerateKey`, `Restore`,
                          `Set`, `SetSAS` and `Update`
  EOF
  type        = any
  default     = []
}

variable "network_acls" {
  description = "ACL roles for the Key Vault"
  type = object({
    bypass         = optional(string, "AzureServices")
    default_action = optional(string, "Allow")
    ip_rules       = optional(list(string), [])
    subnet_associations = optional(list(object({
      subnet_name = optional(string)
      vnet_name   = optional(string)
      rg_name     = optional(string)
    })), [])
  })
  default = null
}

variable "enable_rbac_authorization" {
  type        = bool
  description = <<EOF
  Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of
   data actions.
  EOF
  default     = false
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Is Purge Protection enabled for this Key Vault?"
  default     = false
}

variable "soft_delete_retention_days" {
  type        = string
  description = <<EOF
  The number of days that items should be retained for once soft-deleted. This value can be 
  between 7 and 90 (the default) days.
  EOF
  default     = "90"
}

variable "diagnostic_setting" {
  description = <<EOF
  The description of parameters for Diagnostic Setting:
    `name` - specifies the name of the Diagnostic Setting;
    `log_analytics_workspace_id` - ID of the Log Analytics Workspace;
    `eventhub_name` - Specifies the name of the Event Hub where Diagnostics Data should be sent;
    `eventhub_authorization_rule_id` - Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data;
    `storage_account_id` - the ID of the Storage Account where logs should be sent;
    `log_category` - The list of Diagnostic Log Category's names for this Resource. list of available logs: `AuditEvent`, `AzurePolicyEvaluationDetails`;
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
  type        = map(any)
  description = "A mapping of tags to assign to the resources."
  default     = {}
}
