variable "nsg_name" {
  description = "Specifies the name of the network security group."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the network security group."
  type        = string
}

variable "inbound_rules" {
  description = <<EOF
  A list of collection of inbound rules.
  `name` - (Required) the name of the security rule. This needs to be unique across all Rules in the Network Security Group;
  `description ` - (Optional) a description for this rule. Restricted to 140 characters;
  `priority` - (Required) specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be
   unique for each rule in the collection. The lower the priority number, the higher the priority of the rule;
  `access` - (Optional) pecifies whether network traffic is allowed or denied. Possible values are Allow and Deny;
  `protocol` - (Required) network protocol this rule applies to. Possible values include "Tcp", "Udp", "Icmp", "Esp", "Ah" or "*" (which matches all);
  `source_address_prefix` - (Optional) list of source address prefixes. Tags may not be used. 
   This is required if source_address_prefix is not specified;
  `source_port_range` - (Optional) the number of source port;
  `source_port_ranges` - (Optional) list of source ports or port ranges;
  `destination_port_range`- (Optional) the number of destination port;
  `destination_port_ranges` - (Optional)  list of destination ports or port ranges;
  `source_address_prefix` - (Optional) CIDR or source IP range or * to match any IP. Tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used;
  `source_address_prefixes` - (Optional) list of source address prefixes. Tags may not be used;
  `destination_address_prefix` - (Optional) CIDR or destination IP range or * to match any IP. Tags such as "VirtualNetwork",
    "AzureLoadBalancer" and "Internet" can also be used;
  `destination_address_prefixes` - (Optional) list of destination address prefixes. Tags may not be used;
  `destination_asg` - (Optional) the list of map of destination ASG data:
  "name" - the name of destination ASG;
  "rg_name" - the name of Resource Groupe of destination ASG.
  `source_asg` - the list of map of source ASG data:
  "name" - the name of source ASG;
  "rg_name" - the name of Resource Groupe of source ASG.
  EOF
  type        = any
  default     = []
}

variable "outbound_rules" {
  description = <<EOF
  A list of collection of outbound rules.
  `name` - (Required) the name of the security rule. This needs to be unique across all Rules in the Network Security Group;
  `description ` - (Optional) a description for this rule. Restricted to 140 characters;
  `priority` - (Required) specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be
   unique for each rule in the collection. The lower the priority number, the higher the priority of the rule;
  `access` - (Optional) pecifies whether network traffic is allowed or denied. Possible values are Allow and Deny;
  `protocol` - (Required) network protocol this rule applies to. Possible values include "Tcp", "Udp", "Icmp", "Esp", "Ah" or "*" (which matches all);
  `source_address_prefix` - (Optional) list of source address prefixes. Tags may not be used. 
   This is required if source_address_prefix is not specified;
  `source_port_range` - (Optional) the number of source port;
  `source_port_ranges` - (Optional) list of source ports or port ranges;
  `destination_port_range`- (Optional) the number of destination port;
  `destination_port_ranges` - (Optional) list of destination ports or port ranges;
  `source_address_prefix` - (Optional) CIDR or source IP range or * to match any IP. Tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used;
  `source_address_prefixes` - (Optional) list of source address prefixes. Tags may not be used;
  `destination_address_prefix` - (Optional) CIDR or destination IP range or * to match any IP. Tags such as "VirtualNetwork",
    "AzureLoadBalancer" and "Internet" can also be used;
  `destination_address_prefixes` - (Optional) list of destination address prefixes. Tags may not be used;
  `destination_asg` - (Optional) the list of map of destination ASG data:
  "name" - the name of destination ASG;
  "rg_name" - the name of Resource Groupe of destination ASG.
  `source_asg` - the list of map of source ASG data:
  "name" - the name of source ASG;
  "rg_name" - the name of Resource Groupe of source ASG.
  EOF
  type        = any
  default     = []
}

variable "location" {
  description = <<EOF
    Specifies the supported Azure location where the resource exists.
    If the parameter is not specified in the configuration file, the location of the resource group is used.
  EOF
  type        = string
  default     = null
}

variable "subnet_associate" {
  description = <<EOF
   A list of maps collection of associated subnets:
   `subnet_name` - the name of Subnet;
   `vnet_name` - the name of VNET;
   `rg_name` - the name of subnets Resouce Group.
  EOF
  type        = list(any)
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
    `log_category` - The list of Diagnostic Log Category's names for this Resource. list of available logs: `NetworkSecurityGroupEvent`, `NetworkSecurityGroupRuleCounter`;
    `log_category_group` - The list of Diagnostic Log Category's Group for this Resource. list of available logs: `allLogs`;
  EOF
  type = object({
    name                           = string
    log_analytics_workspace_id     = optional(string)
    storage_account_id             = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    log_category                   = optional(list(string))
    log_category_group             = optional(list(string))
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