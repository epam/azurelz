variable "name" {
  type        = string
  description = "Specifies the name of Management Group"
  default     = null
}

variable "display_name" {
  type        = string
  description = "A friendly name for this Management Group"
}

variable "parent_mg_id" {
  type        = string
  description = "The ID of the Parent Management Group. Changing this forces a new resource to be created"
  default     = null
}

variable "role_assignment_list" {
  type = list(object({
    role        = string
    object_id   = string
    description = string
  }))
  description = <<EOF
    
    The list of role assignments for users in this Management Group.
    Possible arguments are:
    `role`      - The role wich should be assigned to the Management Group
    `object_id` - The Object ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. 
                  Changing this forces a new resource to be created.
    EOF
  default     = []
}

variable "subscription_association_list" {
  type        = list(any)
  description = "The list of subscription IDs which should be associated with Management Group"
  default     = []
}