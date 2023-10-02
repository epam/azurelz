variable "name" {
  description = "The name of the virtual network peering"
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network peering"
  type        = string
}
variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}
variable "remote_virtual_network_id" {
  description = "The full Azure resource ID of the remote virtual network"
  type        = string
}
variable "allow_virtual_network_access" {
  description = "Controls if the VMs in the remote virtual network can access VMs in the local virtual network. Defaults to true"
  type        = bool
  default     = true
}
variable "allow_forwarded_traffic" {
  description = "Controls if forwarded traffic from VMs in the remote virtual network is allowed. Defaults to false"
  type        = bool
  default     = false
}
variable "allow_gateway_transit" {
  description = "Controls gatewayLinks can be used in the remote virtual network's link to the local virtual network"
  type        = bool
  default     = false
}
variable "use_remote_gateways" {
  description = <<EOF
  Controls if remote gateways can be used on the local virtual network. If the flag is set to true, and allow_gateway_transit
  on the remote peering is also true, virtual network will use gateways of remote virtual network for transit
  EOF
  type        = bool
  default     = false
}