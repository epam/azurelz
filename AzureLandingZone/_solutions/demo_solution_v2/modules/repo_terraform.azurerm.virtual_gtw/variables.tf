variable "name" {
  description = "The name of the Virtual Network Gateway."
  type        = string
}

variable "location" {
  description = <<EOF
  The location/region where the Virtual Network Gateway is located.
  If not specified - RG location will be used.
  EOF
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Virtual Network Gateway."
  type        = string
}

variable "type" {
  description = "The type of the Virtual Network Gateway. Valid options are Vpn or ExpressRoute."
  type        = string
  default     = "Vpn"
}

variable "vpn_type" {
  description = <<EOF
  The routing type of the Virtual Network Gateway. Valid options are RouteBased or PolicyBased.
  Defaults to RouteBased.
  EOF
  default     = "RouteBased"
  type        = string
}

variable "active_active" {
  description = <<EOF
  If true, an active-active Virtual Network Gateway will be created. An active-active gateway
  requires a HighPerformance or an UltraPerformance sku. If false, an active-standby gateway
  will be created.
  EOF
  default     = false
  type        = bool
}

variable "enable_bgp" {
  description = <<EOF
  If true, BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway.
  Defaults to false.
  EOF
  default     = false
  type        = bool
}

variable "sku" {
  description = "Configuration of the size and capacity of the virtual network gateway."
  type        = string
  default     = "Basic"
}

variable "generation" {
  description = <<EOF
  The Generation of the Virtual Network gateway. Possible values include Generation1,
  Generation2 or None.
  EOF
  type        = string
  default     = "None"
}

variable "ip_configuration" {
  description = <<EOF
  A configuration map which contains vnet and ip data for assining public ip:
  `subnet_name` - the subnet name of the gateway subnet of a virtual network in
  which the virtual network gateway will be created.
  `vnet_name` - the VNET name in which the virtual network gateway will be created.
  It is mandatory that the associated subnet is named GatewaySubnet. Therefore,
  each virtual network can contain at most a single Virtual Network Gateway.
  `vnet_rg_name` - the VNET resource group in which the virtual network gateway will be created.
  It is mandatory that the associated subnet is named GatewaySubnet. Therefore,
  each virtual network can contain at most a single Virtual Network Gateway.
  `public_ip_name` - the public IP address name to associate with the Virtual Network Gateway
  `public_ip_rg_name` - the public IP address resource group to associate with the Virtual Network Gateway.
  EOF
  type        = map(string)
}

variable "active_active_ip_configurations" {
  description = <<EOF
  An active-active gateway requires exactly two ip_configuration blocks whereas
  an active-active zone redundant gateway with P2S configuration requires exactly
  three ip_configuration blocks.
  EOF
  type        = map(string)
  default     = {}
}

variable "connection" {
  description = <<EOF
  Map that describes configuration values for this virtual gateways connection.
  If not specified no connection will be created.
  Keys and value explanation:
  connection = {
    ### Required
    name = # Name of the connection
    type = # Can be `ExpressRoute`, `IPsec`, `Vnet2Vnet`
    ### Required based on type
    express_route_circuit_id        = # Only when type = ExpressRoute
    local_network_gateway_id        = # Only when type = IPsec
    peer_virtual_network_gateway_id = # Only when type = Vnet2Vnet
    express_route_key               = # Authorization key for express route
    ipsec_key                       = # IPSec key for IPsec
    ### Optional keys, default values shown on right
    dpd_timeout_seconds          = 0         # Dead peer detection timeout in seconds
    express_route_gateway_bypass = false     # "Should data packets will bypass ExpressRoute Gateway for data forwarding
    connection_mode              = "Default" # Possible values are `Default`, `InitiatorOnly` and `ResponderOnly`
    enable_bgp                   = false     # Should BGP be enabled for this connection
    routing_weight               = 0         # Routing weight
  }
  EOF
  type        = map(string)
  default     = null
  sensitive   = true
}

variable "local_network_gateway" {
  description = <<EOF
  Map that describes configuration values for local network gateway.
  If not specified no local network gateway will be created.
  
  Keys and value explanation:
  local_network_gateway = {
    ### Required
    name     = # Name of the connection
    location = # The location of the local network gateway
    ### Optional keys
    gateway_address = # The gateway IP address to connect with
    gateway_fqdn    = # The gateway FQDN to connect with
    address_space   = # The list of string CIDRs representing the address spaces the gateway exposes
    bgp_settings    = # The map containing the Local Network Gateway's BGP speaker settings
  }
  EOF  
  type        = any
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}