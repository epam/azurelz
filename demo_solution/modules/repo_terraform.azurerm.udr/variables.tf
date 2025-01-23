variable "name" {
  description = "The name of the route."
  type        = string
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the route."
  type        = string
}

variable "routes" {
  description = <<EOF
    A collection of defined routes.
    The routes settings:
    `name` - the name of route
    `address_prefix` - the destination to which the route applies.Can be CIDR (such as 10.1.0.0/16) or Azure Service Tag format.
    `next_hop_type` - The type of Azure hop the packet should be sent to. Possible values are `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` and `None`
    `next_hop_in_ip_address` - Contains the IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is `VirtualAppliance`

    Example:
    ```
    routes = [
      {
        name                   = "example-name"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.1"
      }  
    EOF
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string, null)
  }))
}

variable "subnet_associate" {
  description = "A collection of subnets id."
  type = list(object({
    subnet_id = string
  }))
}

variable "disable_bgp_route_propagation" {
  description = "Boolean flag which controls propagation of routes learned by BGP on that route table. True means disable."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
