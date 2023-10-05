variable "initiative_name" {
  description = "The display name of the initiatives to assign to a subscription"
  type        = string
}

variable "assignment_location" {
  description = "The location of this policy initiative assigment"
  type        = string
  default     = null
}

variable "assignment_parameters" {
  description = <<EOF
  A mapping of any parameters for this policy, changing this forces a new policy
  assigment to be created
  EOF
  type        = map(string)
  default     = null
}

variable "enforce" {
  description = "Specifies if this Policy should be enforced or no"
  type        = bool
  default     = false
}

variable "description" {
  description = "The description of the policy set definition"
  type        = string
  default     = null
}

variable "management_group_name" {
  description = "The name of the Management Group where this policy should be defined."
  type        = string
  default     = null
}

variable "policy_definition_list" {
  description = <<EOF
    A collection of policiy defenitions.
    `policy_name`      - Policy name
    `parameter_values` - Parameter values for the referenced policy rule. This field
    is a JSON string that allows you to assign parameters to this policy rule.
    EOF
  type = list(object({
    policy_name      = string
    parameter_values = string
  }))
  default = []
}

variable "scope" {
  description = "Assignment scope for the policy set. Posible values: management_group, subscription"
  type        = string
}

variable "display_name" {
  description = "The display name of the policy set definition."
  type        = string
}

variable "assignment_name" {
  description = "The name of the policy set definition assignment"
  type        = string
  default     = null
}

variable "policy_type" {
  description = "The policy set type. Possible values are BuiltIn or Custom."
  type        = string
  default     = "BuiltIn"
}

variable "initiatives_store" {
  description = "The Management Group where the Policy Set Definition should be stored"
  type        = string
  default     = null
}

variable "create_set_definition" {
  description = "Bool flag to create Policy Set Definition"
  type        = bool
  default     = false
}

variable "assignment_exemptions" {
  description = <<EOF
A map of exemptions for specific resources(management group, subscription, resource group
or resource) for the policy assignment. Scope must be either `management_group`,
`resource_group`, `subscription` or `resource`. Value for `exemption_category` can be
either `Waiver` or `Mitigated`
EOF
  type        = map(map(string))
  default     = null
}

variable "assignment_exclusions" {
  description = <<EOF
  A list of resource IDs(subscription, resource group, resource) to exclude from this
  policy assignment
  EOF
  type        = list(string)
  default     = []
}

variable "identity" {
  description = ""
  type = object({
    type         = string
    identity_ids = list(string)
  })
  default = {
    type         = "SystemAssigned"
    identity_ids = null
  }
}