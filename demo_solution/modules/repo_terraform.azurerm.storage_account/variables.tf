variable "rg_name" {
  description = "Name of the resource group to be imported."
  type        = string
}

variable "storage_name" {
  description = "Name of storage account to be created."
  type        = string
}

variable "location" {
  description = <<EOT
    "Specifies the supported Azure location where the resource exists."
    If the parameter is not specified in the configuration file, the location of the resource group is used.
    EOT
  type        = string
  default     = null
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account."
  type        = string
  default     = "Standard"
}

variable "account_kind" {
  description = "Defines the Kind of account."
  type        = string
  default     = "StorageV2"
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account."
  type        = string
  default     = "GRS"
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the storage account."
  type        = string
  default     = "TLS1_2"
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2"
  type        = string
  default     = "Hot"
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow public access to all nested items in the storage account"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled?"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key"
  type        = bool
  default     = false
}

variable "infrastructure_encryption_enabled" {
  description = "Is infrastructure encryption enabled? Changing this forces a new resource to be created"
  type        = bool
  default     = false
}

variable "blob_delete_retention_day" {
  description = "Specifies the number of days that the blob should be retained, between 1 and 365 days. Defaults to 7"
  type        = number
  default     = 7
}

variable "versioning_enabled" {
  description = "Is versioning enabled?"
  type        = bool
  default     = false
}

variable "change_feed_enabled" {
  description = "Is the blob service properties for change feed events enabled? "
  type        = bool
  default     = false
}

variable "change_feed_retention_in_days" {
  description = <<EOF
  "The duration of change feed events retention in days. The possible values are between 1 and 146000 days (400 years).
   Setting this to null (or omit this in the configuration file) indicates an infinite retention of the change feed."
  EOF
  type        = number
  default     = null
}

variable "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled?"
  type        = bool
  default     = false
}

variable "large_file_share_enabled" {
  description = "Is Large File Share Enabled?"
  type        = bool
  default     = false
}

variable "enable_https_traffic_only" {
  description = "Boolean flag which forces HTTPS if enabled"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the resource."
  type        = map(string)
  default     = {}
}

variable "diagnostic_setting" {
  description = <<EOF
  The description of parameters for Diagnostic Setting:
    `name` - specifies the name of the Diagnostic Setting;
    `log_analytics_workspace_id` - ID of the Log Analytics Workspace;
    `eventhub_name` - Specifies the name of the Event Hub where Diagnostics Data should be sent;
    `eventhub_authorization_rule_id` - Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data;
    `storage_account_id` - the ID of the Storage Account where logs should be sent;
    `metric` - The list of Diagnostic Metric Category's names for this Resource. List of available Metrics: `Transaction`;
  EOF
  type = object({
    name                           = string
    log_analytics_workspace_id     = optional(string)
    storage_account_id             = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    metric                         = optional(list(string))
  })
  default = null
}

variable "network_rules" {
  description = <<EOF
  Firewall settings for storage account:
    `bypass` - Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. 
      Valid options are any combination of "Logging", "Metrics", "AzureServices", or "None".
    `default_action` - Specifies the default action of allow or deny when no other rules match. 
      Valid options are "Deny" or "Allow".
    `ip_rules` - List of public IP or IP ranges in CIDR Format. Only IPv4 addresses are allowed.
      Private IP address ranges (as defined in RFC 1918) are not allowed.
    `subnet_associations` - A list of resource ids for subnets
    `external_subnet_ids` - A list of external ids for subnets
  
  EOF
  type = object({
    bypass         = string
    default_action = string
    ip_rules       = list(string)
    subnet_associations = list(object({
      subnet_name = string
      vnet_name   = string
      rg_name     = string
    }))
    external_subnet_ids = list(string)
  })
  default = null
}

variable "container_collection" {
  description = <<EOF
  A list of objects which contains parameters:
    `name` - The name of the Container which should be created within the Storage Account. Changing this forces a new resource to be created.
    `container_access_type` - The Access Level configured for this Container. Possible values are "blob", "container" or "private".
  EOF
  type = list(object({
    name                  = string
    container_access_type = string
  }))
  default = []
}

variable "share_collection" {
  description = <<EOF
  A list of objects which contains parameters: name, quota, enabled_protocol:
    `name` - The name of the share. Must be unique within the storage account where the share is located.
    `access_tier` - The access tier of the File Share. Possible values are "Hot", "Cool" and "TransactionOptimized", "Premium".
    `enabled_protocol` - The protocol used for the share. Possible values are "SMB" and "NFS"
    `quota` - The maximum size of the share, in gigabytes. For Standard storage accounts, this must be 1GB (or higher)
      and at most 5120 GB (5 TB). For Premium FileStorage storage accounts, this must be greater than 100 GB and at most 102400 GB (100 TB).
  EOF
  type = list(object({
    name             = string
    access_tier      = string
    enabled_protocol = string
    quota            = string
  }))
  default = []
}

variable "azure_files_authentication" {
  description = <<EOF
`directory_type` -  Specifies the directory service used. Possible values - AD;
`active_directory` - Required when directory_type is AD:
  `storage_sid` - Specifies the security identifier (SID) for Azure Storage.
  `domain_name` - Specifies the primary domain that the AD DNS server is authoritative for.
  `domain_sid` - Specifies the security identifier (SID).
  `domain_guid` - Specifies the domain GUID.
  `forest_name` - Specifies the Active Directory forest.
  `netbios_domain_name` - Specifies the NetBIOS domain name.
  EOF
  type        = any
  default     = {}
}

variable "customer_managed_key" {
  description = <<EOF
  Manage a Customer Managed Key for a Storage Account.
  `storage_account_id` -  The ID of the Storage Account. Changing this forces a new resource to be created.
  `key_name` - The name of Key Vault Key.
  `key_vault_id` - The ID of the Key Vault. Exactly one of managed_hsm_key_id, key_vault_id, or key_vault_uri must be specified.
  `key_vault_uri` -  URI pointing at the Key Vault. Required when using federated_identity_client_id.
  `managed_hsm_key_id` - Key ID of a key in a managed HSM. 
  `key_version` - The version of Key Vault Key. Remove or omit this argument to enable Automatic Key Rotation.
  `user_assigned_identity_id` - The ID of a user assigned identity.
  `federated_identity_client_id` - The Client ID of the multi-tenant application to be used in conjunction with the user-assigned identity for cross-tenant customer-managed-keys server-side encryption on the storage account.
  EOF
  type = object({
    key_name                     = string
    storage_account_id           = optional(string)
    key_vault_id                 = optional(string)
    key_vault_uri                = optional(string)
    key_version                  = optional(string)
    user_assigned_identity_id    = optional(string)
    federated_identity_client_id = optional(string)
  })
  default = null
}

variable "sas_policy" {
  description = <<EOF
  `expiration_period` - The SAS expiration period in format of DD.HH:MM:SS.
  `expiration_action` - The SAS expiration action. The only possible value is Log at this moment. Defaults to Log
  EOF
  type = object({
    expiration_period = string
    expiration_action = optional(string)
  })
  default = null
}

variable "logging" {
  description = <<EOF
  `delete` - Indicates whether all delete requests should be logged.
  `read` - Indicates whether all read requests should be logged.
  `version` - The version of storage analytics to configure.
  `write` - Indicates whether all write requests should be logged.
  `retention_policy_days` - Specifies the number of days that logs will be retained.
  EOF
  type = object({
    delete                = bool
    read                  = bool
    version               = string
    write                 = bool
    retention_policy_days = optional(number)
  })
  default = null
}

variable "identity" {
  description = <<EOF
  An identity block supports the following:
  `type` -  Specifies the type of Managed Service Identity that should be configured on this Storage Account.
  `identity_ids` -  A list of User Assigned Managed Identity IDs to be assigned to this Storage Account.
  EOF
  type = object({
    type         = string
    identity_ids = list(string)
  })
  default = null
}