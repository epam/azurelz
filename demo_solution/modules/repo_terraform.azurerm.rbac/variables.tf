variable "definition" {
  description = <<EOF
Variables for creating the Role Definition. If this block is not described, the Role Definition will not be created.
`name` - (Required) The name of the Role Definition. Changing this forces a new resource to be created.
`scope` -  (Required) The scope at which the Role Definition applies too.
`description` - A description of the Role Definition.
`role_definition_id` - (Optional) Specifies the ID of the Role Definition as a UUID/GUID.
`assignable_scopes` - One or more assignable scopes for this Role Definition, such as 
/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333, /subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333/resourceGroups/myGroup,
or /subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333/resourceGroups/myGroup/providers/Microsoft.Compute/virtualMachines/myVM.
`permissions` - Role definition permissions (See [Azure Resource Manager resource provider operations]
(https://docs.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations) for details):
      `actions` - (Optional) One or more Allowed Actions.
      `data_actions` - (Optional) One or more Allowed Data Actions.
      `not_actions` - (Optional) One or more Disallowed Actions.
      `not_data_actions` -  (Optional) One or more Disallowed Data Actions.
EOF
  type = object({
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
  })
  default = null
}

variable "assignment" {
  description = <<EOF
Variables for creating the role assignment. If this block is not described, the Role Definition will not be created.
`scope` - (Required) The scope at which the Role Assignment applies to.
`description` - (Optional) The description for this Role Assignment. Changing this forces a new resource to be created.
`name` - (Optional) A unique UUID/GUID for this Role Assignment - one will be generated if not specified
`role_definition_id` - (Optional) The Scoped-ID of the Role Definition. Changing this forces a new resource to be created. Conflicts with role_definition_name.
`role_definition_name` - (Optional) The name of a built-in Role. Changing this forces a new resource to be created. Conflicts with role_definition_id.
`condition` - (Optional) The condition that limits the resources that the role can be assigned to. Changing this forces a new resource to be created.
`condition_version` - (Optional) The version of the condition. Possible values are 1.0 or 2.0. Changing this forces a new resource to be created.
EOF
  type = object({
    scope                = string
    description          = optional(string)
    name                 = optional(string)
    role_definition_name = optional(string)
    condition            = optional(string)
    condition_version    = optional(string)
  })
  default = null
}

variable "principal_id" {
  description = <<EOF
The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to.
Changing this forces a new resource to be created.
  EOF
  type        = string
  default     = null
}