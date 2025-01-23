base_backend = {
  backend_tfstate_file_path_list = [
    "../base_layer/terraform.tfstate.d/epam.business.env.demo/terraform.tfstate",
    "../base_layer/terraform.tfstate.d/epam.dmz.env.demo/terraform.tfstate",
    "../base_layer/terraform.tfstate.d/epam.gateway.env.demo/terraform.tfstate",
    "../base_layer/terraform.tfstate.d/epam.identity.env.demo/terraform.tfstate",
    "../base_layer/terraform.tfstate.d/epam.shared.env.demo/terraform.tfstate"
  ]
}

vnet_peerings = [
  {
    name                         = "idth-peer-weeu-s-gat-01"
    virtual_network_name         = "idth-vnet-weeu-s-spoke-01"
    resource_group_name          = "idth-rg-weeu-s-network-01"
    remote_virtual_network_name  = "gat-vnet-weeu-s-hub-01"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
  }
]
