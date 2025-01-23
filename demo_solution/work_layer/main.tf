data "terraform_remote_state" "tfstate" {
  count   = var.tfstate_backend != null ? 1 : 0
  backend = var.tfstate_backend.backend
  config = {
    path = var.tfstate_backend.backend_tfstate_file_path
  }
}

data "terraform_remote_state" "base" {
  for_each = toset(var.base_backend.backend_tfstate_file_path_list)
  backend  = var.base_backend.backend
  config = {
    path = each.key
  }
}

module "automation_account" {
  source                  = "../modules/repo_terraform.azurerm.automation_account"
  for_each                = { for automation_account in var.automation_accounts : automation_account.automation_account_name => automation_account }
  automation_account_name = each.value.automation_account_name
  resource_group_name     = each.value.resource_group_name
  sku                     = lookup(each.value, "sku", "Basic")
  location                = lookup(each.value, "location", null)
  identity_type           = each.value.identity_type
  identity_ids            = lookup(each.value, "identity_ids", [])
  runbook                 = lookup(each.value, "runbook", [])
  schedule                = lookup(each.value, "schedule", [])
  job_schedule            = lookup(each.value, "job_schedule", [])
  module                  = lookup(each.value, "module", [])
  webhook                 = lookup(each.value, "webhook", [])
  update_management       = lookup(each.value, "update_management", null)
  diagnostic_setting      = lookup(each.value, "diagnostic_setting", null)
  tags                    = lookup(each.value, "tags", {})
}

module "public_ip" {
  source                  = "../modules/repo_terraform.azurerm.public_ip"
  for_each                = { for public_ip in var.public_ips : public_ip.name => public_ip }
  name                    = each.value.name
  rg_name                 = each.value.rg_name
  location                = each.value.location
  allocation_method       = each.value.allocation_method
  sku                     = each.value.sku
  zones                   = each.value.zones
  ip_version              = each.value.ip_version
  domain_name_label       = lower(each.value.domain_name_label)
  idle_timeout_in_minutes = each.value.idle_timeout_in_minutes
  reverse_fqdn            = each.value.reverse_fqdn
  ddos_protection_mode    = each.value.ddos_protection_mode
  ddos_protection_plan_id = each.value.ddos_protection_plan_id
  diagnostic_setting      = each.value.diagnostic_setting
  tags                    = each.value.tags
}

module "nsg" {
  source              = "../modules/repo_terraform.azurerm.nsg"
  for_each            = { for nsg in var.nsg_list : nsg.nsg_name => nsg }
  inbound_rules       = each.value.inbound_rules
  outbound_rules      = each.value.outbound_rules
  resource_group_name = each.value.resource_group_name
  nsg_name            = each.value.nsg_name
  location            = each.value.location
  subnet_associate    = each.value.subnet_associate
  diagnostic_setting  = each.value.diagnostic_setting
  tags                = each.value.tags
}

module "virtual_gateway" {
  source = "../modules/repo_terraform.azurerm.virtual_gtw"
  depends_on = [
    module.public_ip
  ]
  for_each              = { for virtual_gateway in var.virtual_gateways : virtual_gateway.name => virtual_gateway }
  name                  = each.value.name
  location              = each.value.location
  resource_group_name   = each.value.rg_name
  type                  = each.value.type
  vpn_type              = lookup(each.value, "vpn_type", "RouteBased")
  sku                   = each.value.sku
  generation            = lookup(each.value, "generation", null)
  active_active         = lookup(each.value, "active_active", null)
  enable_bgp            = lookup(each.value, "enable_bgp", false)
  ip_configuration      = each.value.ip_configuration
  connection            = lookup(each.value, "connection", null)
  local_network_gateway = lookup(each.value, "local_network_gateway", null)
  tags                  = lookup(each.value, "tags", {})
}

module "private_dns" {
  source                   = "../modules/repo_terraform.azurerm.private_dns"
  for_each                 = { for dns_zone in var.private_dns_zones : dns_zone.private_dns_zone_name => dns_zone }
  private_dns_zone_rg_name = each.value.private_dns_zone_rg_name
  private_dns_zone_name    = each.value.private_dns_zone_name
  vnet_list                = each.value.vnet_list
  records                  = lookup(each.value, "records", null)
  tags                     = lookup(each.value, "tags", {})
}

module "keyvault" {
  source                          = "../modules/repo_terraform.azurerm.key_vault"
  for_each                        = { for keyvault in var.keyvaults : keyvault.name => keyvault }
  name                            = each.value.name
  resource_group_name             = each.value.rg_name
  location                        = each.value.location
  sku                             = each.value.sku
  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  soft_delete_retention_days      = each.value.soft_delete_retention_days
  public_network_access_enabled   = each.value.public_network_access_enabled
  enable_rbac_authorization       = each.value.enable_rbac_authorization
  network_acls                    = each.value.network_acls
  purge_protection_enabled        = each.value.purge_protection_enabled
  access_policies                 = each.value.access_policies
  diagnostic_setting              = each.value.diagnostic_setting
  tags                            = each.value.tags
}

# Create RBAC
locals {
  # Create RBAC with principal_id except intenty_name and transform it to map
  kv_rbac = flatten([for keyvault in var.keyvaults : flatten([
    [for rbac in keyvault.rbac : {
      principal_id = data.terraform_remote_state.tfstate[0].outputs.identities[rbac.identity_name].principal_id
      assigment    = try(rbac.assigment, null)
      definition   = try(rbac.definition, null)
    } if(try(rbac.identity_name, null) != null && try(rbac.principal_id, null) == null)],
    [for rbac in keyvault.rbac : {
      principal_id = rbac.principal_id
      assigment    = try(rbac.assigment, null)
      definition   = try(rbac.definition, null)
    } if try(rbac.principal_id, null) != null]
  ]) if try(keyvault.rbac, null) != null])
}

module "kv_rbac" {
  source = "../modules/repo_terraform.azurerm.rbac"
  depends_on = [
    module.keyvault
  ]
  for_each     = { for key, value in local.kv_rbac : key => value }
  definition   = try(each.value.definition, null)
  assignment   = try(each.value.assigment, null)
  principal_id = try(each.value.principal_id, null)
}

module "keyvaultcontent" {
  source   = "../modules/repo_terraform.azurerm.key_vault_content"
  for_each = { for keyvaultcontent in var.keyvaultcontents : keyvaultcontent.keyvault_id => keyvaultcontent }
  depends_on = [
    module.kv_rbac
  ]
  keyvault_id         = each.value.keyvault_id
  secrets             = each.value.secrets
  keys                = each.value.keys
  certificate_setting = each.value.certificate_setting
}

# Create RBAC 
locals {
  kvc_rbac = merge([for kv in var.keyvaultcontents :
    { for rbac in kv.rbac :
      "${kv.kv_name}-${rbac.name}" => merge(
        rbac,
        { kv_name = kv.kv_name }
      )
    } if try(kv.rbac, {}) != {}
  ]...)
}

module "kvc_rbac" {
  source = "../modules/repo_terraform.azurerm.rbac"
  depends_on = [
    module.keyvaultcontent
  ]
  for_each     = local.kvc_rbac
  definition   = try(each.value.role_definitions.definition, null)
  assignment   = try(each.value.role_assignments.assigment, null)
  principal_id = try(each.value.role_assignments.principal_id, null)
}

module "storage_account" {
  source                            = "../modules/repo_terraform.azurerm.storage_account"
  for_each                          = { for storage_account in var.storage_accounts : storage_account.storage_name => storage_account }
  storage_name                      = lower(each.value.storage_name)
  rg_name                           = each.value.rg_name
  location                          = each.value.location
  account_tier                      = each.value.account_tier
  account_kind                      = each.value.account_kind
  account_replication_type          = each.value.account_replication_type
  min_tls_version                   = each.value.min_tls_version
  access_tier                       = each.value.access_tier
  public_network_access_enabled     = each.value.public_network_access_enabled
  shared_access_key_enabled         = each.value.shared_access_key_enabled
  infrastructure_encryption_enabled = each.value.infrastructure_encryption_enabled
  change_feed_enabled               = lookup(each.value, "change_feed_enabled", true)
  change_feed_retention_in_days     = lookup(each.value, "change_feed_retention_in_days", null)
  versioning_enabled                = lookup(each.value, "versioning_enabled", false)
  diagnostic_setting                = each.value.diagnostic_setting
  allow_nested_items_to_be_public   = each.value.allow_nested_items_to_be_public
  blob_delete_retention_day         = lookup(each.value, "blob_delete_retention_day", 7)
  large_file_share_enabled          = each.value.large_file_share_enabled
  enable_https_traffic_only         = each.value.enable_https_traffic_only
  is_hns_enabled                    = each.value.is_hns_enabled
  network_rules                     = lookup(each.value, "network_rules", null)
  share_collection                  = lookup(each.value, "share_collection", [])
  container_collection              = lookup(each.value, "container_collection", [])
  azure_files_authentication        = lookup(each.value, "azure_files_authentication", {})
  logging                           = each.value.logging
  customer_managed_key              = each.value.customer_managed_key
  sas_policy                        = each.value.sas_policy
  identity                          = each.value.identity
  tags                              = lookup(each.value, "tags", {})
}

module "private_endpoint" {
  source   = "../modules/repo_terraform.azurerm.private_endpoint"
  for_each = { for privateendpoint in var.privateendpoints : privateendpoint.name => privateendpoint }
  depends_on = [
    module.storage_account,
    module.keyvault
  ]
  name                       = each.value.name
  resource_group_name        = each.value.resource_group_name
  location                   = each.value.location
  subnet_id                  = each.value.subnet_id
  ip_configuration           = each.value.ip_configuration
  private_dns_zone_group     = each.value.private_dns_zone_group
  private_service_connection = each.value.private_service_connection
  tags                       = each.value.tags
}

locals {
  vnet_ids = flatten([
    for vnet in data.terraform_remote_state.base :
    vnet.outputs.vnets[*].vnet_ids if vnet.outputs != {}
  ])
  vnet_names = flatten([
    for vnet in data.terraform_remote_state.base :
    vnet.outputs.vnets[*].vnet_names if vnet.outputs != {}
  ])
  vnet_names_ids_map = zipmap(local.vnet_names, local.vnet_ids)
}

module "vnet_peering" {
  source                       = "../modules/repo_terraform.azurerm.vnet_peering"
  for_each                     = { for vnet_peering in var.vnet_peerings : vnet_peering.name => vnet_peering }
  name                         = each.value.name
  resource_group_name          = each.value.resource_group_name
  virtual_network_name         = each.value.virtual_network_name
  remote_virtual_network_id    = lookup(local.vnet_names_ids_map, each.value.remote_virtual_network_name)
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways
}

module "azure_firewall" {
  source = "../modules/repo_terraform.azurerm.azure_firewall"
  depends_on = [
    module.public_ip
  ]
  for_each                    = { for azure_firewall in var.azure_firewalls : azure_firewall.name => azure_firewall }
  name                        = each.value.name
  location                    = each.value.location
  resource_group_name         = each.value.resource_group_name
  public_ip_address_id        = each.value.public_ip_address_id
  subnet_id                   = each.value.subnet_id
  dns_proxy_enabled           = each.value.dns_proxy_enabled
  dns_servers                 = each.value.dns_servers
  sku_tier                    = each.value.sku_tier
  sku_name                    = each.value.sku_name
  firewall_policy_name        = each.value.firewall_policy_name
  firewall_policy_rg_name     = each.value.firewall_policy_rg_name
  zones                       = each.value.zones
  management_ip_configuration = each.value.management_ip_configuration
  netw_rule_collections       = each.value.netw_rule_collections
  tags                        = each.value.tags
  diagnostic_setting          = each.value.diagnostic_setting
}

module "bastion_host" {
  source = "../modules/repo_terraform.azurerm.bastion_host"
  depends_on = [
    module.public_ip
  ]
  for_each               = { for bastion_host in var.bastion_host : bastion_host.bastion_host_name => bastion_host }
  resource_group_name    = each.value.resource_group_name
  location               = lookup(each.value, "location", null)
  public_ip_address_id   = each.value.public_ip_address_id
  subnet_id              = each.value.subnet_id
  bastion_host_name      = each.value.bastion_host_name
  diagnostic_setting     = lookup(each.value, "diagnostic_setting", null)
  sku                    = lookup(each.value, "sku", "Basic")
  scale_units            = lookup(each.value, "scale_units", "2")
  tunneling_enabled      = lookup(each.value, "tunneling_enabled", false)
  shareable_link_enabled = lookup(each.value, "shareable_link_enabled", false)
  ip_connect_enabled     = lookup(each.value, "ip_connect_enabled", false)
  copy_paste_enabled     = lookup(each.value, "copy_paste_enabled", true)
  file_copy_enabled      = lookup(each.value, "file_copy_enabled", false)
  tags                   = lookup(each.value, "tags", {})
}

locals {
  # Filter out NWK sub as HUB VNETs doesn't need routes configured
  vnet_info = flatten([for vnets in data.terraform_remote_state.tfstate : [
    for vnet in vnets.outputs.vnets : {
      vnet_address_spaces = vnet.vnet_address_spaces
      vnet_name           = vnet.vnet_names
    }
  ]])
  # Generating the default routes for all vnets for GatewaySubnet. If there are multiple
  # address spaces for a vnet then it generate multiple rules and add a suffix
  gateway_routes = flatten([for o in local.vnet_info : [
    for space in o.vnet_address_spaces : {
      "name" = (
        index(o.vnet_address_spaces, space) == 0 ?
        format("%s-to-hubfw", o.vnet_name) :
        format("%s-to-hubfw_%s", o.vnet_name, index(o.vnet_address_spaces, space) + 1)
      )
      address_prefix         = space
      next_hop_type          = var.next_hop_type
      next_hop_in_ip_address = var.firewall_address
    }
  ]])
}

module "udr" {
  source              = "../modules/repo_terraform.azurerm.udr"
  for_each            = { for route_table in var.route_tables : route_table.name => route_table }
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  # When the route table name has "-GatewaySubnet-UDR" in it concatenate the automatically
  # generated rules with the manually configured ones, else just use manual configuration
  routes = (
    length(regexall(".*-gatewaysubnet", each.value.name)) > 0 ?
    concat(each.value.routes, local.gateway_routes) :
    each.value.routes
  )
  subnet_associate              = each.value.subnet_associate
  disable_bgp_route_propagation = each.value.disable_bgp_route_propagation
  tags                          = lookup(each.value, "tags", {})
}

module "app_gateway" {
  source = "../modules/repo_terraform.azurerm.app_gtw"
  depends_on = [
    module.keyvaultcontent,
    module.public_ip
  ]
  for_each                   = { for app_gateway in var.app_gateways : app_gateway.name => app_gateway }
  name                       = each.value.name
  location                   = each.value.location
  resource_group_name        = each.value.rg_name
  zones                      = lookup(each.value, "zones", [])
  tags                       = lookup(each.value, "tags", null)
  enable_http2               = lookup(each.value, "enable_http2", false)
  autoscale_configuration    = lookup(each.value, "autoscale_configuration", null)
  gateway_ip_configurations  = each.value.gateway_ip_configurations
  frontend_ip_configurations = each.value.frontend_ip_configurations
  app_definitions            = each.value.app_definitions
  frontend_ports             = lookup(each.value, "frontend_ports", [])
  ssl_certificates           = lookup(each.value, "ssl_certificates", [])
  trusted_root_certificate   = lookup(each.value, "trusted_root_certificate", [])
  identity_ids               = each.value.identity_ids
  diagnostic_setting         = each.value.diagnostic_setting
  waf_configuration          = lookup(each.value, "waf_configuration", null)
  sku                        = each.value.sku
}

module "vm" {
  source                                                 = "../modules/repo_terraform.azurerm.vm"
  for_each                                               = { for vm in var.vms : vm.vm_name => vm }
  depends_on                                             = [module.keyvaultcontent]
  vm_rg_name                                             = each.value.vm_rg_name
  vm_name                                                = each.value.vm_name
  computer_name                                          = each.value.computer_name
  vm_location                                            = each.value.vm_location
  vm_size                                                = each.value.vm_size
  zone_vm                                                = each.value.zone_vm
  provision_vm_agent                                     = each.value.provision_vm_agent
  custom_data_path                                       = each.value.custom_data_path
  source_custom_image_id                                 = each.value.source_custom_image_id
  source_image_reference                                 = each.value.source_image_reference
  plan                                                   = each.value.plan
  vm_admin_username                                      = each.value.vm_admin_username
  vm_admin_secret_name                                   = each.value.vm_admin_secret_name
  kv_name                                                = each.value.kv_name
  kv_rg_name                                             = each.value.kv_rg_name
  vm_admin_ssh_public_key                                = each.value.vm_admin_ssh_public_key
  vm_guest_os                                            = each.value.vm_guest_os
  license_type_windows                                   = lookup(each.value, "license_type_windows", "None")
  storage_account_type                                   = each.value.storage_account_type
  os_disk_caching                                        = each.value.os_disk_caching
  os_disk_size_gb                                        = each.value.os_disk_size_gb
  data_disks                                             = each.value.data_disks
  patch_mode                                             = each.value.patch_mode
  patch_assessment_mode                                  = each.value.patch_assessment_mode
  bypass_platform_safety_checks_on_user_schedule_enabled = each.value.bypass_platform_safety_checks_on_user_schedule_enabled
  vm_disk_encryption_install                             = each.value.vm_disk_encryption_install
  nic_settings                                           = each.value.nic_settings
  boot_diagnostics                                       = each.value.boot_diagnostics
  diagnostic_setting                                     = each.value.diagnostic_setting
  vm_insights                                            = each.value.vm_insights
  vm_network_watcher_agent_install                       = each.value.vm_network_watcher_agent_install
  post_install_script_path                               = each.value.post_install_script_path
  ad_domain_join                                         = each.value.ad_domain_join
  tags                                                   = each.value.tags
}

module "backup" {
  source = "../modules/repo_terraform.azurerm.recovery_backup"
  depends_on = [
    module.vm
  ]
  for_each           = { for backup in var.backups : backup.backup_resource_id => backup }
  backup_resource_id = each.value.backup_resource_id
  type               = each.value.type
  vault_name         = each.value.vault_name
  vault_rg           = each.value.vault_rg
  policy_id          = each.value.policy_id
  share              = each.value.share
}
