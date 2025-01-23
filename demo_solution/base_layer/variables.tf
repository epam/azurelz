variable "create_duration" {
  description = "Duration for time_sleep resource.This ensures that the management group has sufficient time to become fully interactable before any dependent tasks are executed."
  type        = string
  default     = null  # CUSTOM_LOGIC
}

variable "mg_list_lvl_0" {
  description = "List of parameters for control group level 0"
  type = list(object({
    display_name = string
    name         = optional(string)
    parent_mg_id = optional(string)
    role_assignment_list = optional(list(object({
      role        = string
      object_id   = string
      description = string
    })))
    subscription_association_list = optional(list(any), [])
  }))
  default = []
}

variable "mg_list_lvl_1" {
  description = "List of parameters for control group level 0"
  type = list(object({
    display_name = string
    name         = optional(string)
    parent_mg_id = optional(string)
    role_assignment_list = optional(list(object({
      role        = string
      object_id   = string
      description = string
    })))
    subscription_association_list = optional(list(any), [])
  }))
  default = []
}

variable "mg_list_lvl_2" {
  description = "List of parameters for control group level 0"
  type = list(object({
    display_name = string
    name         = optional(string)
    parent_mg_id = optional(string)
    role_assignment_list = optional(list(object({
      role        = string
      object_id   = string
      description = string
    })))
    subscription_association_list = optional(list(any), [])
  }))
  default = []
}

variable "mg_list_lvl_3" {
  description = "List of parameters for control group level 0"
  type = list(object({
    display_name = string
    name         = optional(string)
    parent_mg_id = optional(string)
    role_assignment_list = optional(list(object({
      role        = string
      object_id   = string
      description = string
    })))
    subscription_association_list = optional(list(any), [])
  }))
  default = []
}

variable "policy_initiatives" {
  description = "List of the parameters for Policy initiatives"
  type = list(object({
    initiative_name       = string
    assignment_location   = optional(string, "westeurope")
    assignment_parameters = optional(map(string), null)
    enforce               = optional(bool, false)
    description           = optional(string)
    management_group_name = optional(string)
    policy_definition_list = optional(list(object({
      policy_name      = string
      parameter_values = string
    })), [])
    scope                 = string
    display_name          = optional(string, null)
    assignment_name       = optional(string)
    policy_type           = optional(string, "BuiltIn")
    initiatives_store     = optional(string)
    create_set_definition = optional(bool, false)
    assignment_exemptions = optional(map(map(string)), null)
    assignment_exclusions = optional(list(string), [])
    identity = optional(object({
      type         = string
      identity_ids = list(string)
      }),
      {
        type         = "SystemAssigned" # CUSTOM_LOGIC
        identity_ids = []
      }
    )
  }))
  default = []
}

variable "rg_list" {
  type = list(object({
    name     = string
    location = optional(string, "westeurope")
    tags     = optional(map(string), {})
  }))
  description = "Resource groups parameters"
  default     = []
}

variable "identity" {
  type = list(object({
    identity_name = string
    location      = optional(string, "westeurope")
    rg_name       = string
    tags          = optional(map(string), {})
  }))
  description = "User assigned identities"
  default     = []
}

variable "logAnalytics" {
  description = "Log Analytics parameters"
  type = list(object({
    name              = string
    rg_name           = string
    location          = optional(string, "westeurope")
    pricing_tier      = optional(string, "PerGB2018")
    retention_in_days = optional(number, 31)
    daily_quota_gb    = optional(number, 70)
    activity_log_subs = optional(list(string), [])
    deployment_mode   = optional(string, "Incremental")
    la_solutions      = optional(list(map(any)), [])
    diagnostic_setting = optional(object({
      name                           = string
      log_analytics_workspace_id     = optional(string)
      storage_account_id             = optional(string)
      eventhub_name                  = optional(string)
      eventhub_authorization_rule_id = optional(string)
      log_category                   = optional(list(string))
      log_category_group             = optional(list(string))
      metric                         = optional(list(string))
    }), null)
    tags = optional(map(string), {})
  }))
  default = []
}

variable "storage_accounts" {
  description = "values for storage account"
  type = list(object({
    storage_name                      = string
    rg_name                           = string
    location                          = optional(string, "westeurope")
    access_tier                       = optional(string, "Hot")
    account_kind                      = optional(string, "StorageV2")
    account_replication_type          = optional(string, "GRS")
    account_tier                      = optional(string, "Standard")
    allow_nested_items_to_be_public   = optional(bool, false)
    azure_files_authentication        = optional(any, {})
    blob_delete_retention_day         = optional(number, 7)
    change_feed_enabled               = optional(bool, false)
    change_feed_retention_in_days     = optional(number, null)
    infrastructure_encryption_enabled = optional(bool, false)
    is_hns_enabled                    = optional(bool, false)
    large_file_share_enabled          = optional(bool, false)
    min_tls_version                   = optional(string, "TLS1_2")
    public_network_access_enabled     = optional(bool, false)
    shared_access_key_enabled         = optional(bool, true)
    versioning_enabled                = optional(bool, false)
    sas_policy = optional(object({
      expiration_period = string
      expiration_action = optional(string)
    }), null)
    share_collection = optional(list(object({
      name             = string
      access_tier      = string
      enabled_protocol = string
      quota            = string
    })), [])
    network_rules = optional(object({
      bypass         = string
      default_action = string
      ip_rules       = list(string)
      subnet_associations = list(object({
        subnet_name = string
        vnet_name   = string
        rg_name     = string
      }))
      external_subnet_ids = list(string)
    }), null)
    logging = optional(object({
      delete                = bool
      read                  = bool
      version               = string
      write                 = bool
      retention_policy_days = optional(number)
    }), null)
    enable_https_traffic_only = optional(bool, true)
    identity = optional(object({
      type         = string
      identity_ids = list(string)
    }), null)
    container_collection = optional(list(object({
      name                  = string
      container_access_type = string
    })), [])
    customer_managed_key = optional(object({
      key_name                     = string
      storage_account_id           = optional(string)
      key_vault_id                 = optional(string)
      key_vault_uri                = optional(string)
      key_version                  = optional(string)
      user_assigned_identity_id    = optional(string)
      federated_identity_client_id = optional(string)
    }), null)
    diagnostic_setting = optional(object({
      name                           = string
      log_analytics_workspace_id     = optional(string)
      storage_account_id             = optional(string)
      eventhub_name                  = optional(string)
      eventhub_authorization_rule_id = optional(string)
      metric                         = optional(list(string))
    }), null)
    tags = optional(map(string), {})
  }))
  default = []
}

variable "vnets" {
  description = "A list of virtual networks"
  type = list(object({
    vnet_name                 = string
    rg_name                   = string
    location                  = optional(string, "westeurope")
    address_space             = optional(list(string), ["10.0.0.0/16"])
    ddos_protection_plan_name = optional(string)
    dns_servers               = optional(list(string), [])
    subnets                   = optional(list(any), [])
    diagnostic_setting = optional(object({
      name                           = string
      log_analytics_workspace_id     = optional(string)
      storage_account_id             = optional(string)
      eventhub_name                  = optional(string)
      eventhub_authorization_rule_id = optional(string)
      log_category                   = optional(list(string))
      log_category_group             = optional(list(string))
      metric                         = optional(list(string))
    }), null)
    tags = optional(map(string), {})
  }))
}

variable "rbac" {
  description = "Role-Based Access Control parameters"
  type = list(object({
    definition = optional(object({
      name               = string
      scope              = string
      description        = optional(string)
      role_definition_id = optional(string)
      assignable_scopes  = optional(list(string), null)
      permissions = optional(object({
        actions          = optional(list(string))
        data_actions     = optional(list(string))
        not_actions      = optional(list(string))
        not_data_actions = optional(list(string))
      }), null)
    }), null)
    assignment = object({
      scope                = string
      description          = optional(string)
      name                 = optional(string)
      role_definition_name = optional(string)
      condition            = optional(string)
      condition_version    = optional(string)
    })
    principal_ids = list(string)
  }))
  default = []
}

variable "locks" {
  description = "Azure management lock on a specified resource."
  type = list(object({
    resource_id = string
    lock_name   = string
    lock_level  = optional(string, "CanNotDelete")
    notes       = optional(string, null)
  }))
  default = []
}