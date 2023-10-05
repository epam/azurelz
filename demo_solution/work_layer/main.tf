# Get data from tfstate files in defined environment (optional)
data "terraform_remote_state" "tfstate" {
  count   = var.backend_tfstate_file_path != null ? 1 : 0
  backend = "local"
  config = {
    path = "${var.backend_tfstate_file_path}/terraform.tfstate"
  }
}
# Get data from tfstate files in all environments (permanent)
data "terraform_remote_state" "base" {
  for_each = toset(var.backend_tfstate_file_path_list)
  backend  = "local"
  config = {
    path = "${each.key}/terraform.tfstate"
  }
}

# 020_automationaccount
# Creating automation accounts
module "automation_account" {
  source                  = "../modules/repo_terraform.azurerm.automation_account"
  for_each                = { for automation_account in var.automation_accounts : automation_account.automation_account_name => automation_account }
  automation_account_name = each.value.automation_account_name
  resource_group_name     = each.value.resource_group_name
  sku                     = try(each.value.sku, "Basic")
  location                = try(each.value.location, null)
  identity_type           = lookup(each.value, "identity_type", "SystemAssigned")
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

# 025_publicip
# Creating public ips
module "public_ip" {
  source                  = "../modules/repo_terraform.azurerm.public_ip"
  for_each                = { for public_ip in var.public_ips : public_ip.name => public_ip }
  name                    = each.value.name
  rg_name                 = each.value.rg_name
  location                = try(each.value.location, null)
  allocation_method       = try(each.value.allocation_method, "Static")
  sku                     = try(each.value.sku, "Standard")
  zones                   = try(each.value.zones, [])
  ip_version              = try(each.value.ip_version, "IPv4")
  domain_name_label       = try(lower(each.value.domain_name_label), null)
  idle_timeout_in_minutes = try(each.value.idle_timeout_in_minutes, 4)
  reverse_fqdn            = try(each.value.reverse_fqdn, null)
  diagnostic_setting      = lookup(each.value, "diagnostic_setting", null)
  tags                    = try(each.value.tags, {})
}

# 030_nsg
# Creating NSGs
module "nsg" {
  source              = "../modules/repo_terraform.azurerm.nsg"
  for_each            = { for nsg in var.nsgs : nsg.name => nsg }
  inbound_rules       = each.value.inbound_rules
  outbound_rules      = each.value.outbound_rules
  resource_group_name = each.value.resource_group_name
  nsg_name            = each.value.name
  location            = each.value.location
  subnet_associate    = try(each.value.subnet_associate, [])
  diagnostic_setting  = lookup(each.value, "diagnostic_setting", null)
  tags                = try(each.value.tags, {})
}

# 030_virtualgtw
# Creating Azure virtual network gateways
module "virtual_gateway" {
  source = "../modules/repo_terraform.azurerm.virtual_gtw"
  depends_on = [
    module.public_ip
  ]
  for_each                        = { for virtual_gateway in var.virtual_gateways : virtual_gateway.name => virtual_gateway }
  name                            = each.value.name
  location                        = each.value.location
  resource_group_name             = each.value.rg_name
  type                            = each.value.type
  vpn_type                        = lookup(each.value, "vpn_type", "RouteBased")
  sku                             = each.value.sku
  generation                      = lookup(each.value, "generation", null)
  active_active                   = lookup(each.value, "active_active", null)
  enable_bgp                      = lookup(each.value, "enable_bgp", false)
  ip_configuration                = each.value.ip_configuration
  active_active_ip_configurations = lookup(each.value, "active_active_ip_configurations", {})
  connection                      = lookup(each.value, "connection", null)
  local_network_gateway           = lookup(each.value, "local_network_gateway", null)
  tags                            = lookup(each.value, "tags", {})
}

# 030_privatedns
# Create private DNS zone
module "private_dns" {
  source                   = "../modules/repo_terraform.azurerm.private_dns"
  for_each                 = { for dns_zone in var.private_dns_zones : dns_zone.private_dns_zone_name => dns_zone }
  private_dns_zone_rg_name = each.value.private_dns_zone_rg_name
  private_dns_zone_name    = each.value.private_dns_zone_name
  vnet_list                = try(each.value.vnet_list, [])
  records                  = lookup(each.value, "records", null)
  tags                     = lookup(each.value, "tags", {})
}

# 035_keyvault
# Get data source subnet
data "azurerm_subnet" "subnet_kv" {
  for_each             = { for kv in var.keyvaults : kv.name => kv if try(kv.private_endpoint, {}) != {} }
  name                 = each.value.private_endpoint.subnet.name
  virtual_network_name = each.value.private_endpoint.subnet.vnet_name
  resource_group_name  = each.value.private_endpoint.subnet.vnet_rg
}

locals {
  # Create access_policies with object_ids except intenty_names
  access_policies = { for keyvault in var.keyvaults : keyvault.name => setunion(
    flatten([for policy in keyvault.access_policies : {
      object_ids              = [for identity_name in policy.identity_names : data.terraform_remote_state.tfstate[0].outputs.identities[identity_name].principal_id]
      storage_permissions     = try(policy.storage_permissions, [])
      secret_permissions      = try(policy.secret_permissions, [])
      certificate_permissions = try(policy.certificate_permissions, [])
      key_permissions         = try(policy.key_permissions, [])
    } if(try(policy.identity_names, null) != null && try(policy.object_ids, null) == null)]),
    [for policy in keyvault.access_policies : {
      object_ids              = policy.object_ids
      storage_permissions     = try(policy.storage_permissions, [])
      secret_permissions      = try(policy.secret_permissions, [])
      certificate_permissions = try(policy.certificate_permissions, [])
      key_permissions         = try(policy.key_permissions, [])
    } if try(policy.object_ids, null) != null]
  ) if try(keyvault.access_policies, null) != null }
}

# Create Key Vault
module "keyvault" {
  source                          = "../modules/repo_terraform.azurerm.key_vault"
  for_each                        = { for keyvault in var.keyvaults : keyvault.name => keyvault }
  name                            = each.value.name
  resource_group_name             = each.value.rg_name
  sku                             = try(each.value.sku, "standard")
  enabled_for_deployment          = try(each.value.enabled_for_deployment, false)
  enabled_for_disk_encryption     = try(each.value.enabled_for_disk_encryption, false)
  enabled_for_template_deployment = try(each.value.enabled_for_template_deployment, false)
  soft_delete_retention_days      = try(each.value.soft_delete_retention_days, "90")
  access_policies                 = try(local.access_policies[each.value.name], [])
  network_acls = try(each.value.network_acls, {
    bypass              = "AzureServices"
    default_action      = "Allow"
    ip_rules            = null
    subnet_associations = []
  })
  purge_protection_enabled  = try(each.value.purge_protection_enabled, false)
  enable_rbac_authorization = try(each.value.enable_rbac_authorization, false)
  diagnostic_setting        = try(each.value.diagnostic_setting, null)
  tags                      = try(each.value.tags, {})
}

# Create endpoint for keyvault
module "kv_private_endpoint" {
  source = "../modules/repo_terraform.azurerm.private_endpoint"
  depends_on = [
    module.keyvault
  ]
  for_each            = { for kv in var.keyvaults : kv.name => kv if try(kv.private_endpoint, {}) != {} }
  name                = each.value.private_endpoint.name
  resource_group_name = each.value.private_endpoint.resource_group_name
  location            = try(each.value.private_endpoint.location, null)
  subnet_id           = data.azurerm_subnet.subnet_kv[each.value.name].id
  private_service_connection = {
    private_connection_resource_id = module.keyvault[each.value.name].id
  }
  tags = try(each.value.private_endpoint.tags, {})
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

# 035_keyvaultcontent
# Create Key Vault
module "keyvaultcontent" {
  source = "../modules/repo_terraform.azurerm.key_vault_content"
  depends_on = [
    module.keyvault,
    module.kv_rbac
  ]
  for_each            = { for keyvaultcontent in var.keyvaultcontents : keyvaultcontent.keyvault_id => keyvaultcontent }
  keyvault_id         = each.value.keyvault_id
  secrets             = try(each.value.secrets, [])
  keys                = try(each.value.keys, [])
  certificate_setting = try(each.value.certificate_setting, [])
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

# 035_storageaccount
# Create storage accounts
module "storage_account" {
  source                            = "../modules/repo_terraform.azurerm.storage_account"
  for_each                          = { for storage_account in var.storage_accounts : storage_account.storage_name => storage_account }
  storage_name                      = lower(each.value.storage_name)
  rg_name                           = each.value.rg_name
  account_tier                      = each.value.account_tier
  account_kind                      = each.value.account_kind
  account_replication_type          = each.value.account_replication_type
  min_tls_version                   = each.value.min_tls_version
  access_tier                       = each.value.access_tier
  public_network_access_enabled     = try(each.value.public_network_access_enabled, null)
  shared_access_key_enabled         = try(each.value.shared_access_key_enabled, null)
  infrastructure_encryption_enabled = try(each.value.infrastructure_encryption_enabled, null)
  change_feed_enabled               = lookup(each.value, "change_feed_enabled", true)
  change_feed_retention_in_days     = lookup(each.value, "change_feed_retention_in_days", null)
  versioning_enabled                = lookup(each.value, "versioning_enabled", false)
  diagnostic_setting                = try(each.value.diagnostic_setting, {})
  allow_nested_items_to_be_public   = each.value.allow_nested_items_to_be_public
  blob_delete_retention_day         = lookup(each.value, "blob_delete_retention_day", 7)
  large_file_share_enabled          = each.value.large_file_share_enabled
  enable_https_traffic_only         = each.value.enable_https_traffic_only
  is_hns_enabled                    = each.value.is_hns_enabled
  network_rules                     = lookup(each.value, "network_rules", null)
  share_collection                  = lookup(each.value, "share_collection", [])
  container_collection              = lookup(each.value, "container_collection", [])
  azure_files_authentication        = lookup(each.value, "azure_files_authentication", {})
  tags                              = lookup(each.value, "tags", {})
}

data "azurerm_subnet" "subnet_sa" {
  for_each             = { for sa in var.storage_accounts : sa.storage_name => sa if try(sa.private_endpoint, {}) != {} }
  name                 = each.value.private_endpoint.subnet.name
  virtual_network_name = each.value.private_endpoint.subnet.vnet_name
  resource_group_name  = each.value.private_endpoint.subnet.vnet_rg
}

module "private_endpoint" {
  source = "../modules/repo_terraform.azurerm.private_endpoint"
  depends_on = [
    module.storage_account
  ]
  for_each            = { for sa in var.storage_accounts : sa.storage_name => sa if try(sa.private_endpoint, {}) != {} }
  name                = each.value.private_endpoint.name
  resource_group_name = each.value.private_endpoint.resource_group_name
  location            = try(each.value.private_endpoint.location, null)
  subnet_id           = data.azurerm_subnet.subnet_sa[each.value.storage_name].id
  private_service_connection = {
    private_connection_resource_id = module.storage_account[each.value.storage_name].storage_account_id
    subresource_names              = try(each.value.private_endpoint.subresource_names, [])
  }
  tags = try(each.value.private_endpoint.tags, {})
}


# 035_vnetpeering
# Create virtual network peering
# Create map with virtual network data: '<name> = <id>'
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

# Create virtual network peering
module "vnet_peering" {
  source                       = "../modules/repo_terraform.azurerm.vnet_peering"
  for_each                     = { for vnet_peering in var.vnet_peerings : vnet_peering.name => vnet_peering }
  name                         = each.value.name
  resource_group_name          = each.value.source_vnet_rg_name
  virtual_network_name         = each.value.source_vnet_name
  remote_virtual_network_id    = lookup(local.vnet_names_ids_map, each.value.destination_vnet_name)
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways
}


# 045_azurefirewall
# Create Azure firewall
module "azure_firewall" {
  source = "../modules/repo_terraform.azurerm.azure_firewall"
  depends_on = [
    module.public_ip
  ]
  for_each                    = { for azure_firewall in var.azure_firewalls : azure_firewall.name => azure_firewall }
  name                        = each.value.name
  location                    = each.value.location
  resource_group_name         = each.value.rg_name
  sku_tier                    = try(each.value.sku_tier, null)
  sku_name                    = try(each.value.sku_name, null)
  firewall_policy_name        = try(each.value.firewall_policy_name, null)
  firewall_policy_rg_name     = try(each.value.firewall_policy_rg_name, null)
  zones                       = try(each.value.zones, null)
  subnet_associate            = try(each.value.subnet_associate, null)
  public_ip_address           = each.value.public_ip_address
  management_ip_configuration = try(each.value.management_ip_configuration, [])
  netw_rule_collections       = try(each.value.netw_rule_collections, [])
  tags                        = try(each.value.tags, null)
  diagnostic_setting          = try(each.value.diagnostic_setting, null)
}

# 050_bastionhost
# Create bastion host
module "bastion_host" {
  source = "../modules/repo_terraform.azurerm.bastion_host"
  depends_on = [
    module.public_ip
  ]
  for_each               = { for bastion_host in var.bastion_host : bastion_host.bastion_host_name => bastion_host }
  resource_group_name    = each.value.resource_group_name
  vnet_rg_name           = lookup(each.value, "vnet_rg_name", null)
  vnet_name              = each.value.vnet_name
  location               = lookup(each.value, "location", null)
  public_ip_address_id   = each.value.public_ip_address_id
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

# 050_udr
# Get vnet information from all spokes
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
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_address
    }
  ]])
}

# Create route table
module "udr" {
  source = "../modules/repo_terraform.azurerm.udr"

  for_each            = { for route_table in var.route_tables : route_table.name => route_table }
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.rg_name
  # When the route table name has "-GatewaySubnet-UDR" in it concatenate the automatically
  # generated rules with the manually configured ones, else just use manual configuration
  routes = (
    length(regexall(".*-gatewaysubnet", each.value.name)) > 0 ?
    concat(each.value.routes, local.gateway_routes) :
    each.value.routes
  )
  subnet_associate              = each.value.subnet_associate
  disable_bgp_route_propagation = each.value.route_propogation == "yes" ? false : true
  tags                          = lookup(each.value, "tags", {})
}

# 055_appgtw
# Create application gateways
module "app_gateway" {
  source = "../modules/repo_terraform.azurerm.app_gtw"
  depends_on = [
    module.keyvault,
    module.keyvaultcontent,
    module.public_ip
  ]
  for_each                   = { for app_gateway in var.app_gateways : app_gateway.name => app_gateway }
  name                       = each.value.name
  location                   = try(each.value.location, null)
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
  identity_ids               = try(each.value.identity_ids, null)
  diagnostic_setting         = try(each.value.diagnostic_setting, null)
  waf_configuration          = lookup(each.value, "waf_configuration", null)
  sku = try(each.value.sku, {
    capacity = "1"
    name     = "Standard_Small"
    tier     = "Standard"
  })
}

# 060_vm
data "azurerm_shared_image" "vm_image" {
  for_each            = { for vm in var.vms : vm.vm_name => vm if try(vm.vm_custom_image, null) != null }
  name                = each.value.vm_custom_image.vm_custom_image_name
  gallery_name        = each.value.vm_custom_image.gallery_name
  resource_group_name = each.value.vm_custom_image.image_rg_name
}

# Create VM
module "vm" {
  source = "../modules/repo_terraform.azurerm.vm"
  depends_on = [
    module.keyvaultcontent
  ]
  for_each                         = { for vm in var.vms : vm.vm_name => vm }
  vm_rg_name                       = each.value.vm_rg_name
  vm_name                          = each.value.vm_name
  computer_name                    = try(each.value.computer_name, null)
  vm_location                      = try(each.value.vm_location, null)
  vm_size                          = try(each.value.vm_size, "Standard_D4s_v3")
  zone_vm                          = try(each.value.zone_vm, null)
  provision_vm_agent               = try(each.value.provision_vm_agent, true)
  custom_data_path                 = try(each.value.custom_data_path, null)
  source_custom_image_id           = try(each.value.source_custom_image_id, try(data.azurerm_shared_image.vm_image[each.key].id, null))
  source_image_reference           = try(each.value.source_image_reference, null)
  plan                             = try(each.value.plan, null)
  vm_admin_username                = each.value.vm_admin_username
  vm_admin_secret_name             = try(each.value.vm_admin_secret_name, "")
  kv_name                          = each.value.kv_name
  kv_rg_name                       = each.value.kv_rg_name
  vm_admin_ssh_public_key          = try(each.value.vm_admin_ssh_public_key, null)
  vm_guest_os                      = try(each.value.vm_guest_os, "windows")
  license_type_windows             = lookup(each.value, "license_type_windows", "None")
  storage_account_type             = try(each.value.storage_account_type, "Standard_LRS")
  os_disk_caching                  = try(each.value.os_disk_caching, "ReadWrite")
  os_disk_size_gb                  = try(each.value.os_disk_size_gb, null)
  data_disks                       = try(each.value.data_disks, null)
  vm_disk_encryption_install       = try(each.value.vm_disk_encryption_install, null)
  nic_settings                     = each.value.nic_settings
  boot_diagnostics                 = try(each.value.boot_diagnostics, null)
  diagnostic_setting               = try(each.value.diagnostic_setting, null)
  vm_insights                      = try(each.value.vm_insights, null)
  vm_network_watcher_agent_install = try(each.value.vm_network_watcher_agent_install, false)
  post_install_script_path         = try(each.value.post_install_script_path, null)
  ad_domain_join                   = try(each.value.ad_domain_join, null)
  tags                             = try(each.value.tags, {})
}

# Create backup for Virtual Machine
data "azurerm_backup_policy_vm" "policy" {
  depends_on = [
    module.vm
  ]
  for_each            = { for vm in var.vms : vm.vm_name => vm if try(vm.backup, {}) != {} }
  name                = each.value.backup.policy_name
  recovery_vault_name = each.value.backup.vault_name
  resource_group_name = each.value.backup.vault_rg
}

module "backup" {
  source = "../modules/repo_terraform.azurerm.recovery_backup"
  depends_on = [
    data.azurerm_backup_policy_vm.policy
  ]
  for_each           = { for vm in var.vms : vm.vm_name => vm if try(vm.backup, {}) != {} }
  type               = "vm"
  backup_resource_id = each.value.vm_guest_os == "windows" ? module.vm[each.value.vm_name].windows_vm_id : module.vm[each.value.vm_name].linux_vm_id
  policy_id          = data.azurerm_backup_policy_vm.policy[each.value.vm_name].id
  vault_name         = each.value.backup.vault_name
  vault_rg           = each.value.backup.vault_rg
  share              = each.value.backup.share
}
