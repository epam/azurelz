variable "name" {
  type        = string
  description = "Specifies the Name of the Private Endpoint. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = <<EOF
    Specifies the Name of the Resource Group within which the Private Endpoint should exist.
    Changing this forces a new resource to be created.
  EOF
}

variable "location" {
  type        = string
  description = "The supported Azure location where the resource exists. Changing this forces a new resource to be created."
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint. Changing this forces a new resource to be created."
}

variable "private_service_connection" {
  type = object({
    is_manual_connection              = optional(bool, false)
    private_connection_resource_id    = optional(string, null)
    private_connection_resource_alias = optional(string, null)
    subresource_names                 = optional(list(string), null)
    request_message                   = optional(string, null)
  })
  description = <<EOF
    A private_service_connection block supports the following:
    `is_manual_connection` - Does the Private Endpoint require Manual Approval from the remote resource owner?
    Changing this forces a new resource to be created.
    NOTE:
    If you are trying to connect the Private Endpoint to a remote resource without having the correct RBAC
    permissions on the remote resource set this value to true.
    `private_connection_resource_id` - (Optional) The ID of the Private Link Enabled Remote Resource which this
    Private Endpoint should be connected to. Changing this forces a new resource to be created. For a web app or
    function app slot, the parent web app should be used in this field instead of a reference to the slot itself.
    `private_connection_resource_alias` - (Optional) The Service Alias of the Private Link Enabled Remote Resource which
    this Private Endpoint should be connected to. Changing this forces a new resource to be created.
    `subresource_names` - (Optional) A list of subresource names which the Private Endpoint is able to connect to.
    subresource_names corresponds to group_id. Possible values are detailed in the product documentation in the Subresources
    column. Changing this forces a new resource to be created.
    `request_message` - (Optional) A message passed to the owner of the remote resource when the private endpoint attempts
    to establish the connection to the remote resource. The request message can be a maximum of 140 characters in length. 
    Only valid if is_manual_connection is set to true.
  EOF
  default     = {}
  validation {
    condition     = (var.private_service_connection.private_connection_resource_id != null && var.private_service_connection.private_connection_resource_alias == null) || (var.private_service_connection.private_connection_resource_id == null && var.private_service_connection.private_connection_resource_alias != null)
    error_message = "One of private_connection_resource_id or private_connection_resource_alias must be specified."
  }
}

variable "private_dns_zone_group" {
  type = object({
    name                 = string
    private_dns_zone_ids = list(string)
  })
  description = <<EOF
    A private_dns_zone_group block supports the following::
    `name` - Specifies the Name of the Private DNS Zone Group.
    `private_dns_zone_ids` - Specifies the list of Private DNS Zones to include within the private_dns_zone_group.
  EOF
  default     = null
}

variable "ip_configuration" {
  type = object({
    private_ip_address = string
    subresource_name   = optional(string, null)
    member_name        = optional(string, null)
  })
  description = <<EOF
    An ip_configuration block supports the following:
    `name` - (Required) Specifies the Name of the IP Configuration. Changing this forces a new resource to be created.
    `private_ip_address` - (Required) Specifies the static IP address within the private endpoint's subnet to be used.
    Changing this forces a new resource to be created.
    `subresource_name` - Specifies the subresource this IP address applies to. subresource_names corresponds
    to group_id. Changing this forces a new resource to be created.
    `member_name` - Specifies the member name this IP address applies to. If it is not specified, it will use
    the value of subresource_name. Changing this forces a new resource to be created.
  EOF
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
