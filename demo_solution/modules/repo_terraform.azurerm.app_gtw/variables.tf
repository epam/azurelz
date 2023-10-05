variable "name" {
  description = "The name of the Application Gateway."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to the Application Gateway should exist."
  type        = string
}

variable "location" {
  description = <<EOF
    Specifies the supported Azure location where the resource exists.
    If the parameter is not specified in the configuration file, the location of the resource group is used.
  EOF
  default     = null
  type        = string
}

variable "sku" {
  description = <<EOT
  The map which contains the sku parameters:
  `name`     - (Required) The Name of the SKU to use for this Application Gateway. Possible values are 
               Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2.
  `tier`     - (Required) The Tier of the SKU to use for this Application Gateway. Possible values are
               Standard, Standard_v2, WAF and WAF_v2. 
  `capacity` - (Required) The Capacity of the SKU to use for this Application Gateway. When using a
               V1 SKU this value must be between 1 and 32, and 1 to 125 for a V2 SKU. This property is optional
               if autoscale_configuration is set. 
  EOT 
  type = object({
    name     = string
    tier     = string
    capacity = string
  })
  default = {
    capacity = "1"
    name     = "Standard_Small"
    tier     = "Standard"
  }
}

variable "autoscale_configuration" {
  description = <<EOT
  A map which contains:
  `min_capacity` - the minimum capacity for autoscaling
  `max_capacity` - the maximum capacity for autoscaling
  EOT
  type = object({
    min_capacity = string
    max_capacity = string
  })
  default = null
}

variable "zones" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = list(string)
  default     = []
}

variable "enable_http2" {
  description = " Is HTTP2 enabled on the application gateway resource?"
  type        = bool
  default     = false
}

variable "gateway_ip_configurations" {
  description = <<EOT
  A collection of maps which contain ip configurations of the application gateway: 
  `name`         - The Name of this Gateway IP Configuration.
  `subnet_name`  - the Subnet name which the Application Gateway should be connected to.
  `vnet_name`    - the VNET name which the Application Gateway should be connected to.
  `vnet_rg_name` - the VNET resource group which the Application Gateway should be connected to.
  EOT 
  type = list(object({
    name         = string
    subnet_name  = string
    vnet_name    = string
    vnet_rg_name = string
  }))
}

variable "frontend_ip_configurations" {
  description = <<EOT
  A collection of maps which contains frontend ip configuration parameters:
  `name` - the name of the Frontend IP Configuration
  `public_ip_name` - the Public IP Address name which the Application Gateway should use.
  The allocation method for the Public IP Address depends on the sku of this Application
  Gateway. Please refer to the Azure documentation for public IP addresses for details.
  `public_ip_rg_name` - the Public IP Address resource group which the Application Gateway
  should use.
  EOT
  type = list(object({
    name              = string
    public_ip_name    = string
    public_ip_rg_name = string
  }))
}

variable "app_definitions" {
  description = "A list of backend pool configuration."
  type = list(object({
    app_suffix = optional(string, "myapp")
    backend_address_pool = object({
      name         = optional(string)
      fqdns        = optional(list(string))
      ip_addresses = optional(list(string))
    })
    backend_http_settings = object({
      cookie_based_affinity               = optional(string, "Disabled")
      affinity_cookie_name                = optional(string)
      path                                = optional(string)
      port                                = string
      probe_name                          = optional(string)
      protocol                            = string
      request_timeout                     = optional(number, 30)
      host_name                           = optional(string)
      pick_host_name_from_backend_address = optional(bool, false)
      trusted_root_certificate_names      = optional(list(string))
      authentication_certificate = optional(list(object({
        name = string
      })), [])
      connection_draining = optional(object({
        enabled           = bool
        drain_timeout_sec = number
      }))
    })
    http_listener = object({
      frontend_ip_configuration_name = string
      frontend_port_name             = string
      host_names                     = optional(list(string))
      protocol                       = string
      require_sni                    = optional(bool, false)
      ssl_certificate_name           = optional(string)
      custom_error_configuration = optional(list(object({
        status_code           = string
        custom_error_page_url = string
      })), [])
      firewall_policy_id = optional(string)
      ssl_profile_name   = optional(string)
    })
    request_routing_rule = object({
      rule_type                   = optional(string, "Basic")
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name       = optional(string)
      priority                    = optional(number, 100)
      backend_address_pool_name   = optional(string)
    })
    probe = optional(object({
      host                                      = optional(string)
      name                                      = optional(string)
      interval                                  = optional(number, 30)
      protocol                                  = string
      path                                      = string
      timeout                                   = optional(number, 60)
      unhealthy_threshold                       = optional(number, 3)
      port                                      = optional(number)
      pick_host_name_from_backend_http_settings = optional(bool, false)
      match = optional(object({
        body        = optional(string)
        status_code = list(string)
      }))
      minimum_servers = optional(number, 0)
    }))
  }))
}

variable "frontend_ports" {
  description = <<EOT
  A collection of maps which contain frontend ports configurations:
  `name` - The name of the Frontend Port.
  `port` - The port used for this Frontend Port.
  EOT
  type = list(object({
    name = string
    port = string
  }))
}

variable "ssl_certificates" {
  description = <<EOT
  A collection of maps which contain ssl certificates data:
  `kv_name`      - the Key Vault name where certificate stores;
  `kv_rg_name`   - the Key Vault resource group where certificate stores;
  `kv_cert_name` - the name of the certificate stored in the Key Vault.
  EOT 
  type = list(object({
    kv_name      = string
    kv_rg_name   = string
    kv_cert_name = string
  }))
  default = []
}

variable "trusted_root_certificate" {
  description = <<EOT
  A collection of maps which contain trusted ssl certificates data: 
  `kv_name`      - the Key Vault name where certificate stores
  `kv_rg_name`   - the Key Vault resource group where certificate stores
  `kv_cert_name` - the certificate name in Key Vault
  `data`         - (Optional) The contents of the Trusted Root Certificate which should be used.
  EOT 
  type = list(object({
    kv_name      = string
    kv_rg_name   = string
    kv_cert_name = string
    data         = string
  }))
  default = []
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Application Gateway."
  type        = list(string)
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
    `log_category` - The list of Diagnostic Log Category's names for this Resource. list of available logs: `ApplicationGatewayAccessLog`, `ApplicationGatewayFirewallLog`, `ApplicationGatewayPerformanceLog`;
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

variable "waf_configuration" {
  description = "Parameters for WAF."

  type = object({
    enabled          = bool
    firewall_mode    = string
    rule_set_type    = string
    rule_set_version = string
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}