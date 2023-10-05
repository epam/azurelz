# Get resource group data
data "azurerm_resource_group" "vm_rg" {
  count = var.vm_location == null ? 1 : 0
  name  = var.vm_rg_name
}

# Get Subnet data
data "azurerm_subnet" "vmsubnet" {
  for_each             = { for nic in var.nic_settings : "${nic.nic_vnet_name}-${nic.nic_subnet_name}" => nic }
  name                 = each.value.nic_subnet_name
  virtual_network_name = each.value.nic_vnet_name
  resource_group_name  = each.value.nic_vnet_rg_name
}

# Get the subscription Id
data "azurerm_client_config" "current" {}

# Get KV data
data "azurerm_key_vault" "kek_kv" {
  count               = var.vm_disk_encryption_install != null ? 1 : 0
  name                = var.kv_name
  resource_group_name = var.kv_rg_name
}

data "azurerm_key_vault_secret" "admin_secret" {
  count        = var.vm_admin_ssh_public_key == null ? 1 : 0
  name         = local.vm_admin_secret_name
  key_vault_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.kv_rg_name}/providers/Microsoft.KeyVault/vaults/${var.kv_name}"
}

locals {
  vm_admin_secret_name = var.vm_admin_secret_name == "" ? var.vm_admin_username : var.vm_admin_secret_name
}

data "azurerm_key_vault_secret" "ad_user_secret" {
  count        = var.ad_domain_join != null ? 1 : 0
  name         = var.ad_domain_join.username_secret
  key_vault_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.kv_rg_name}/providers/Microsoft.KeyVault/vaults/${var.kv_name}"
}

# Create PIP
resource "azurerm_public_ip" "vm" {
  for_each            = { for nic in var.nic_settings : "${nic.nic_vnet_name}-${nic.nic_subnet_name}" => nic if nic.public_ip != null }
  name                = format("%s-%s-PIP", var.vm_name, each.key)
  location            = var.vm_location == null ? data.azurerm_resource_group.vm_rg[0].location : var.vm_location
  resource_group_name = var.vm_rg_name
  allocation_method   = try(each.value.public_ip.vm_pip_allocation_method, "Static")
  sku                 = try(each.value.public_ip.sku, "Basic")
  domain_name_label   = var.vm_name
  zones               = try(each.value.public_ip.zone_pip, ["Zone-Redundant"])
  tags                = var.tags == null ? {} : var.tags
}

# Create NIC
resource "azurerm_network_interface" "vmnic" {
  for_each                      = { for nic in var.nic_settings : "${nic.nic_vnet_name}-${nic.nic_subnet_name}" => nic }
  name                          = format("%s-%s-NIC", var.vm_name, each.key)
  location                      = var.vm_location == null ? data.azurerm_resource_group.vm_rg[0].location : var.vm_location
  resource_group_name           = var.vm_rg_name
  tags                          = var.tags == null ? {} : var.tags
  enable_accelerated_networking = try(each.value.enable_accelerated_networking, false)
  enable_ip_forwarding          = try(each.value.enable_ip_forwarding, false)

  ip_configuration {
    primary                       = try(index(var.nic_settings, each.value), 1) == 0 ? true : false
    name                          = format("%s-%s-ipcfg", var.vm_name, each.key)
    subnet_id                     = data.azurerm_subnet.vmsubnet[each.key].id
    private_ip_address_allocation = try(each.value.vm_private_ip_allocation_method, "Dynamic")
    private_ip_address            = try(each.value.vm_private_ip_allocation_method, "Dynamic") == "Static" ? try(each.value.vm_private_ip_address, null) : null
    public_ip_address_id          = each.value.public_ip != null ? azurerm_public_ip.vm[each.key].id : null
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
      mac_address,
      virtual_machine_id
    ]
  }
}

# Get application security group data
data "azurerm_application_security_group" "asg" {
  for_each            = { for nic in var.nic_settings : "${nic.nic_vnet_name}-${nic.nic_subnet_name}" => nic if nic.nsg_config != null && try(nic.nsg_config.nsg_association_type, null) == "asg" }
  name                = each.value.nsg_config.nsg_association_name
  resource_group_name = each.value.nsg_config.nsg_association_rg
}

# Get network security group data
data "azurerm_network_security_group" "nsg" {
  for_each            = { for nic in var.nic_settings : "${nic.nic_vnet_name}-${nic.nic_subnet_name}" => nic if nic.nsg_config != null && try(nic.nsg_config.nsg_association_type, null) == "nsg" }
  name                = each.value.nsg_config.nsg_association_name
  resource_group_name = each.value.nsg_config.nsg_association_rg
}

# Create nic interface application security group association
resource "azurerm_network_interface_application_security_group_association" "asg_association" {
  for_each                      = { for nic in var.nic_settings : "${nic.nic_vnet_name}-${nic.nic_subnet_name}" => nic if nic.nsg_config != null && try(nic.nsg_config.nsg_association_type, null) == "asg" }
  network_interface_id          = azurerm_network_interface.vmnic[each.key].id
  application_security_group_id = data.azurerm_application_security_group.asg[each.key].id
}

# Create nic interface network security group association
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  for_each                  = { for nic in var.nic_settings : "${nic.nic_vnet_name}-${nic.nic_subnet_name}" => nic if nic.nsg_config != null && try(nic.nsg_config.nsg_association_type, null) == "nsg" }
  network_interface_id      = azurerm_network_interface.vmnic[each.key].id
  network_security_group_id = data.azurerm_network_security_group.nsg[each.key].id
}

resource "azurerm_managed_disk" "datadisks" {
  for_each             = var.data_disks != null ? var.data_disks : {}
  name                 = format("%s-%s", var.vm_name, each.key)
  location             = var.vm_location == null ? data.azurerm_resource_group.vm_rg[0].location : var.vm_location
  resource_group_name  = var.vm_rg_name
  storage_account_type = lookup(each.value, "storage_account_type", null) == null ? var.storage_account_type : each.value.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = lookup(each.value, "disk_size_gb", null) == null ? "128" : each.value.disk_size_gb
  zone                 = var.zone_vm
  tags                 = var.tags == null ? {} : var.tags

  lifecycle {
    # Ignore changes to encryption_settings as these are modified by vm extension
    ignore_changes = [
      encryption_settings,
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisks" {
  for_each           = var.data_disks != null ? var.data_disks : {}
  managed_disk_id    = azurerm_managed_disk.datadisks[each.key].id
  virtual_machine_id = var.vm_guest_os == "windows" ? azurerm_windows_virtual_machine.vm_windows[0].id : azurerm_linux_virtual_machine.vm_linux[0].id
  lun                = lookup(each.value, "lun", "10" + index(keys(var.data_disks), each.key))
  caching            = lookup(each.value, "caching", "None")
}

# Windows VM NO DataDisk
resource "azurerm_windows_virtual_machine" "vm_windows" {
  count                      = var.vm_guest_os == "windows" ? 1 : 0
  name                       = var.vm_name
  location                   = var.vm_location == null ? data.azurerm_resource_group.vm_rg[0].location : var.vm_location
  resource_group_name        = var.vm_rg_name
  size                       = var.vm_size
  network_interface_ids      = values(azurerm_network_interface.vmnic)[*].id
  computer_name              = var.computer_name == null ? var.vm_name : var.computer_name
  admin_username             = var.vm_admin_username
  admin_password             = data.azurerm_key_vault_secret.admin_secret[0].value
  license_type               = var.license_type_windows
  provision_vm_agent         = var.provision_vm_agent
  allow_extension_operations = var.provision_vm_agent
  zone                       = var.zone_vm
  custom_data                = var.custom_data_path == null ? null : filebase64(var.custom_data_path)
  tags                       = var.tags == null ? {} : var.tags
  source_image_id            = try(var.source_custom_image_id, null)

  dynamic "source_image_reference" {
    for_each = var.source_image_reference != null ? [var.source_image_reference] : []
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = try(source_image_reference.value.version, "latest")
    }
  }

  dynamic "plan" {
    for_each = var.plan != null ? [var.plan] : []
    content {
      name      = plan.value.name
      publisher = plan.value.publisher
      product   = plan.value.product
    }
  }

  os_disk {
    name                 = format("%s-MDK001", var.vm_name)
    caching              = var.os_disk_caching
    storage_account_type = var.storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics != null ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics.storage_account_uri
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

# Linux VM NO DataDisk
resource "azurerm_linux_virtual_machine" "vm_linux" {
  count                           = var.vm_guest_os == "linux" ? 1 : 0
  name                            = var.vm_name
  location                        = var.vm_location == null ? data.azurerm_resource_group.vm_rg[0].location : var.vm_location
  resource_group_name             = var.vm_rg_name
  size                            = var.vm_size
  network_interface_ids           = values(azurerm_network_interface.vmnic)[*].id
  computer_name                   = var.computer_name == null ? var.vm_name : var.computer_name
  admin_username                  = var.vm_admin_username
  admin_password                  = var.vm_admin_ssh_public_key == null ? sensitive(data.azurerm_key_vault_secret.admin_secret[0].value) : null
  provision_vm_agent              = var.provision_vm_agent
  allow_extension_operations      = var.provision_vm_agent
  disable_password_authentication = var.vm_admin_ssh_public_key == null ? false : true
  zone                            = var.zone_vm
  custom_data                     = var.custom_data_path == null ? null : filebase64(var.custom_data_path)
  tags                            = var.tags == null ? {} : var.tags
  source_image_id                 = var.source_custom_image_id

  dynamic "source_image_reference" {
    for_each = var.source_image_reference != null ? [var.source_image_reference] : []
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = try(source_image_reference.value.version, "latest")
    }
  }

  dynamic "plan" {
    for_each = var.plan != null ? [var.plan] : []
    content {
      name      = plan.value.name
      publisher = plan.value.publisher
      product   = plan.value.product
    }
  }

  os_disk {
    name                 = format("%s-MDK001", var.vm_name)
    caching              = var.os_disk_caching
    storage_account_type = var.storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics != null ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics.storage_account_uri
    }
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "admin_ssh_key" {
    for_each = var.vm_admin_ssh_public_key != null ? [1] : []
    content {
      username   = var.vm_admin_username
      public_key = var.vm_admin_ssh_public_key
    }
  }
}

###########################################################################################
# Create RSA KEK for encryption BEK
###########################################################################################

resource "azurerm_virtual_machine_extension" "vm_disk_encryption" {
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.datadisks,
    azurerm_virtual_machine_extension.vm_diagnostic_setting,
    azurerm_virtual_machine_extension.post-install-script,
    azurerm_virtual_machine_extension.da,
    azurerm_virtual_machine_extension.ama
  ]
  count                      = var.vm_disk_encryption_install != null ? 1 : 0
  name                       = format("%s-disk-encryption", var.vm_name)
  virtual_machine_id         = var.vm_guest_os == "windows" ? azurerm_windows_virtual_machine.vm_windows[0].id : azurerm_linux_virtual_machine.vm_linux[0].id
  publisher                  = "Microsoft.Azure.Security"
  type                       = var.vm_guest_os == "windows" ? "AzureDiskEncryption" : "AzureDiskEncryptionForLinux"
  type_handler_version       = var.vm_guest_os == "windows" ? "2.2" : "1.1"
  auto_upgrade_minor_version = true
  tags                       = var.tags == null ? {} : var.tags
  settings                   = <<PROTECTED_SETTINGS
    {
        "EncryptionOperation":    "${lookup(var.vm_disk_encryption_install, "encrypt_operation", "EnableEncryption")}",
        "KeyVaultURL":            "${data.azurerm_key_vault.kek_kv[0].vault_uri}",
        "KeyVaultResourceId":     "${data.azurerm_key_vault.kek_kv[0].id}",					
        "KeyEncryptionKeyURL":    "${lookup(var.vm_disk_encryption_install, "encryption_kek_url", null)}",
        "KekVaultResourceId":     "${data.azurerm_key_vault.kek_kv[0].id}",					
        "KeyEncryptionAlgorithm": "${lookup(var.vm_disk_encryption_install, "encryption_algorithm", "RSA-OAEP")}",
        "VolumeType":             "${lookup(var.vm_disk_encryption_install, "volume_type", "All")}"
    } 
  PROTECTED_SETTINGS
}


###########################################################################################
# Set VM diagnostic setting extension
# LinuxDiagnostic required Python2
###########################################################################################

resource "azurerm_virtual_machine_extension" "vm_diagnostic_setting" {
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.datadisks,
    azurerm_linux_virtual_machine.vm_linux
  ]
  count                      = var.diagnostic_setting != null ? 1 : 0
  name                       = format("%s-DGS001", var.vm_name)
  virtual_machine_id         = var.vm_guest_os == "windows" ? azurerm_windows_virtual_machine.vm_windows[0].id : azurerm_linux_virtual_machine.vm_linux[0].id
  publisher                  = "Microsoft.Azure.Diagnostics"
  type                       = var.vm_guest_os == "windows" ? "IaaSDiagnostics" : "LinuxDiagnostic"
  type_handler_version       = var.vm_guest_os == "windows" ? "1.9" : "4.0"
  auto_upgrade_minor_version = true
  tags                       = var.tags == null ? {} : var.tags
  settings                   = var.vm_guest_os == "windows" ? local.windows_diagnostic_settings : local.linux_diagnostic_settings
  protected_settings         = var.vm_guest_os == "windows" ? local.windows_diagnostic_protected_settings : local.linux_diagnostic_protected_settings
}

###########################################################################################
# Network watcher agent
###########################################################################################

resource "azurerm_virtual_machine_extension" "nw_agent" {
  count                      = var.vm_network_watcher_agent_install == true ? 1 : 0
  name                       = format("%s-network-watcher-agent", var.vm_name)
  virtual_machine_id         = var.vm_guest_os == "windows" ? azurerm_windows_virtual_machine.vm_windows[0].id : azurerm_linux_virtual_machine.vm_linux[0].id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = var.vm_guest_os == "windows" ? "NetworkWatcherAgentWindows" : "NetworkWatcherAgentLinux"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  tags                       = var.tags == null ? {} : var.tags
}

###########################################################################################
# Post install script
###########################################################################################

resource "azurerm_virtual_machine_extension" "post-install-script" {
  count                = var.post_install_script_path != null ? 1 : 0
  name                 = "post-install-script"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  virtual_machine_id   = var.vm_guest_os == "windows" ? azurerm_windows_virtual_machine.vm_windows[0].id : azurerm_linux_virtual_machine.vm_linux[0].id
  settings             = <<SETTINGS
    {
        "script": "${filebase64(var.post_install_script_path)}"
    }
  SETTINGS
}

###########################################################################################
# Join an Azure virtual machine into an AD Domain
###########################################################################################

resource "azurerm_virtual_machine_extension" "join-domain" {
  count                      = var.ad_domain_join != null ? 1 : 0
  name                       = format("%s-join-domain", var.vm_name)
  virtual_machine_id         = var.vm_guest_os == "windows" ? azurerm_windows_virtual_machine.vm_windows[0].id : azurerm_linux_virtual_machine.vm_linux[0].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true
  tags                       = var.tags == null ? {} : var.tags

  settings = <<SETTINGS
    {
        "Name": "${var.ad_domain_join.domain}",
        "OUPath": "${try(var.ad_domain_join.ou_path, null) != null ? var.ad_domain_join.ou_path : ""}",
        "User": "${var.ad_domain_join.username}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${data.azurerm_key_vault_secret.ad_user_secret[0].value}"
    }
SETTINGS
}

###########################################################################################
# Enable VM Insights
###########################################################################################

# Install Monitoring Agent
resource "azurerm_virtual_machine_extension" "ama" {
  for_each                   = toset(var.vm_insights != null ? ["enabled"] : [])
  name                       = format("%s-%s", var.vm_name, var.vm_guest_os == "windows" ? "AzureMonitorWindowsAgent" : "AzureMonitorLinuxAgent")
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = var.vm_guest_os == "windows" ? "AzureMonitorWindowsAgent" : "AzureMonitorLinuxAgent"
  type_handler_version       = var.vm_guest_os == "windows" ? "1.14" : "1.25"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  virtual_machine_id = var.vm_guest_os == "windows" ? azurerm_windows_virtual_machine.vm_windows[0].id : azurerm_linux_virtual_machine.vm_linux[0].id

  settings = jsonencode({
    GCS_AUTO_CONFIG = true
    workspaceId     = var.vm_insights.workspace_id
  })

  protected_settings = sensitive(jsonencode({
    workspaceKey = var.vm_insights.workspace_key
  }))

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Install Dependency Agent
resource "azurerm_virtual_machine_extension" "da" {
  for_each                   = toset(var.vm_insights != null ? ["enabled"] : [])
  name                       = format("%s-%s", var.vm_name, var.vm_guest_os == "windows" ? "DependencyAgentWindows" : "DependencyAgentLinux")
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = var.vm_guest_os == "windows" ? "DependencyAgentWindows" : "DependencyAgentLinux"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true

  virtual_machine_id = var.vm_guest_os == "windows" ? azurerm_windows_virtual_machine.vm_windows[0].id : azurerm_linux_virtual_machine.vm_linux[0].id

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
