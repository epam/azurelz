# 001_mg
variable "mg_list_lvl_0" {
  default     = []
  type        = any
  description = "List of parameters for control group level 0"
}
variable "mg_list_lvl_1" {
  default     = []
  type        = any
  description = "List of parameters for control group level 1"
}
variable "mg_list_lvl_2" {
  default     = []
  type        = any
  description = "List of parameters for control group level 2"
}
variable "mg_list_lvl_3" {
  default     = []
  type        = any
  description = "List of parameters for control group level 3"
}

# 004_policyinitiative
variable "policy_initiatives" {
  type        = any
  description = "The parameters of Policy initiatives"
  default     = []
}

# 005_rg
variable "rg_list" {
  type        = any
  description = "Resource groups parameters"
  default     = []
}

# 006_useridentity
variable "user_identities" {
  type = list(object({
    name     = string
    rg_name  = string
    location = optional(string)
    tags     = optional(map(string), {})
  }))
  description = "User identities parameters"
  default     = []
}

# 010_loganalytics
variable "logAnalytics" {
  type        = any
  description = "LogAnalytics parameters"
  default     = []
}

# 025_vnet
variable "vnets" {
  description = "A list of virtual networks"
  type = list(object({
    vnet_name                 = string
    rg_name                   = string
    location                  = optional(string)
    address_space             = optional(list(string), ["10.0.0.0/16"])
    ddos_protection_plan_name = optional(string)
    dns_servers               = optional(list(string), [])
    subnets                   = optional(any, [])
    diagnostic_setting        = optional(any, null)
    tags                      = optional(map(string), {})
  }))
  default = []
}
