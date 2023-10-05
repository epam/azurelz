variable "vm_rg_name" {
  description = "The name of the Resource Group where the Virtual Machine will be placed."
  type        = string
}

variable "vm_location" {
  description = "The VM location. If not specified - RG location will be used."
  type        = string
  default     = null
}

variable "vm_name" {
  description = "The VM name (must be unique for each VM to create)."
  type        = string
}

variable "computer_name" {
  description = <<EOF
  The hostname of the virtual machine. Must be no longer than 15 characters for Windows. 
  For Linux VM each element of the hostname must be from 1 to 63 characters long and the 
  entire hostname, including the dots, can be at most 253 characters long.
  EOF
  type        = string
  default     = null
}

variable "vm_size" {
  description = "The SKU which should be used for this Virtual Machine."
  type        = string
  default     = "Standard_D4s_v3"
}

variable "os_disk_size_gb" {
  description = "The Size of the Internal OS Disk in GB"
  type        = number
  default     = null
}

variable "zone_vm" {
  description = <<EOF
  The Availability Zone in which this Virtual Machine and managed data disks
  should be created. Allowed values are `null`, `1`, `2` and `3`. VM and data
  disks don't use Availability Zones.
  EOF
  type        = string
  default     = null
}

variable "provision_vm_agent" {
  description = "Specifies whether the Azure VM agent should be providsioned for this VM"
  type        = bool
  default     = true
}

variable "custom_data_path" {
  description = "Custom Data file path which should be used for this Virtual Machine"
  type        = string
  default     = null
}

variable "vm_admin_username" {
  description = <<EOF
  The username of the local administrator used for the Virtual Machine. Changing
  this forces a new resource to be created. Also used for the name of the secret
  which contains the VM password stored in the keyvault.
  EOF
  type        = string
}

variable "vm_admin_secret_name" {
  description = <<EOF
  The name of the secret which stores the administrator password in the Key Vault.
  If its not provided the value of `admin_username` will be used as a name.
  EOF
  type        = string
  default     = ""
  sensitive   = true
}

variable "kv_name" {
  description = "The Azure Key Vault name where the initial admin passwords or/and encryption key are stored."
  type        = string
}

variable "kv_rg_name" {
  description = "The Azure Key Vault resource group where the initial admin passwords or/and encryption key are stored."
  type        = string
}

variable "vm_admin_ssh_public_key" {
  description = <<EOF
  The Public Key which should be used for authentication, which needs to be at least
  2048-bit and in `ssh-rsa` format. Like: `ssh-rsa A12s....oU5NDQ== myuser@hostname`
  EOF
  type        = string
  sensitive   = true
  default     = null
}

# VM OS & image related variables
variable "vm_guest_os" {
  description = "The type of the guest OS. Possible values are `windows` and `linux`."
  type        = string
  default     = "windows"
}

variable "license_type_windows" {
  description = <<EOF
  Specifies the type of on-premise license (also known as Azure Hybrid Use Benefit)
  which should be used for this Virtual Machine. Possible values are `None`,
  `Windows_Client` and `Windows_Server`.
  EOF
  type        = string
  default     = "None"
}

variable "source_custom_image_id" {
  description = "The Id of a custom vm image"
  type        = string
  default     = null
}

variable "source_image_reference" {
  description = <<EOF
    A map contains the image's parameters:
    `publisher`: Specifies the publisher of the image used to create the virtual machines.
    `offer`: Specifies the offer of the image used to create the virtual machines.
    `sku`: Specifies the SKU of the image used to create the virtual machines.
    `version`: Specifies the version of the image used to create the virtual machines. 
    By default uses latest.
  EOF
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = optional(string, "latest")
  })
  default = null
}

variable "plan" {
  description = <<EOF
  A map containing the marketplace image's: `publisher`, `name`, `product`. See more:
  https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage#check-the-purchase-plan-information
  EOF
  type = object({
    name      = string
    publisher = string
    product   = string
  })
  default = null
}
variable "nic_settings" {
  description = <<EOF
  Virtual network interface card configuration. A mapping of setting:
  `nic_vnet_name`: The virtual network name.
  `nic_vnet_rg_name`: The virtual network's resource group.
  `nic_subnet_name`: The subnet name to use for this VM.
  `enable_ip_forwarding`: OptiSpecifies if ip forwarding should be enabled on the network interface.
  `enable_accelerated_networking`: Specifies if accelerated networking should be enabled on the
  network interface.
  `vm_private_ip_allocation_method`: The allocation method used for the Private IP Address.
  Possible values are `Static` or `Dynamic`.
  `vm_private_ip_address`: The VM private ip address. If `vm_private_ip_allocation_method` set
  as `Dynamic` - vm_private_ip_address not used.
  
  `public_ip`: An object containing Public IP configuration:
       `vm_pip_allocation_method`: Defines the allocation method for this public IP address.
                                   Possible values are `Static` or `Dynamic`.
       `sku`: The SKU of the Public IP. Accepted values are Basic and Standard.
       `zone_pip`: The Zone in which this public ip should be created.
  For Network Interface configuration without Public IP thise parameter should be added as `public_ip = null`
  `nsg_config`:   A mapping of network security group (application security group) settings:
       `nsg_association_type`: Describes security association type - NSG or ASG, therefore
                               it should be equal asg or nsg values only.
       `nsg_association_rg`: NSG/ASG resource group.
       `nsg_association_name`: NSG/ASG name. This parameter required if `nsg_config` block was configured.
  nsg_config disabled by default.
  EOF
  type = list(object({
    nic_vnet_name                   = string
    nic_vnet_rg_name                = string
    nic_subnet_name                 = string
    enable_ip_forwarding            = optional(bool, false)
    enable_accelerated_networking   = optional(bool, false)
    vm_private_ip_allocation_method = optional(string, "Dynamic")
    vm_private_ip_address           = optional(string)
    public_ip = optional(object({
      vm_pip_allocation_method = optional(string, "Static")
      sku                      = optional(string, "Basic")
      zone_pip                 = optional(list(string), [])
    }))
    nsg_config = optional(object({
      nsg_association_type = string
      nsg_association_rg   = string
      nsg_association_name = string
    }), null)
  }))
}

# OS disk related variables
variable "storage_account_type" {
  description = <<EOF
  The Type of Storage Account which should back this the Internal OS Disk.
  Possible values are `Standard_LRS`, `StandardSSD_LRS` and `Premium_LRS`.
  EOF
  type        = string
  default     = "Standard_LRS"
}

variable "os_disk_caching" {
  description = <<EOF
  The Type of Caching which should be used for the Internal OS Disk.
  Possible values are `None`, `ReadOnly` and `ReadWrite`.
  EOF
  type        = string
  default     = "ReadWrite"
}

# Data disk related variables
variable "data_disks" {
  description = <<EOF
  Additional data disks to add to the VM, use this if you want to add multiple datadisks. Disk names consist of
  VM name and disk prefix (that is specified in `data_disks` object member).
  A map contains next elements:
  `storage_account_type`: The Type of Storage Account which should back the data disk, if not supplied
  same will be used as for the OS disk. Possible values are `Standard_LRS`, `StandardSSD_ZRS`,
  `Premium_LRS`, `Premium_ZRS`, `StandardSSD_LRS` or `UltraSSD_LRS`. By default equal 
  `storage_account_type`.
  `disk_size_gb`: The size of the data disk in GB. By default equal 128 GB.
  `lun`: The Logical Unit Number of the Data Disk, which needs to be unique within the Virtual
  Machine. Changing this forces a new resource to be created. By default equal 10. Note: lun's are
  starting from 10 and each disk will increase that by 1 or you can configure it manually, but you have
  to configure for all of them to exclude conflicts.
  `caching`: Specifies the caching requirements for this Data Disk. Possible values are: `None`,
  `ReadOnly` and `ReadWrite`. By default equal None.
    Disk name like MDK001 and MDK002 used as disk name prefix with VM name combination.
  
  EOF
  type        = any
  default     = null
}

# Disk encryption related variables
variable "vm_disk_encryption_install" {
  description = <<EOF
  Specifies whether to install Disk encryption or not. A mapping of disk encryption setting:
  `encryption_kek_url`: Required if `vm_disk_encryption_install` configured. The URL
  of the KEK used for disk encryption.
  `encrypt_operation`: Optional. Default EnableEncryption. The encryption operation.
  `volume_type`: Optional. Default All. Type of volume that the encryption operation
  is performed on. Valid values are OS, Data, and All. Encryption operations on data
  volume need encryption to be enabled OS volume first.
  `encryption_algorithm`: Optional. Default RSA-OAEP. Algorithm used for the disk 
  encryption.
  `vm_disk_encryption_install` disabled by default
  EOF
  type = object({
    encryption_kek_url   = string
    encrypt_operation    = optional(string)
    volume_type          = optional(string)
    encryption_algorithm = optional(string)
  })
  default = null
}

variable "vm_network_watcher_agent_install" {
  description = "Specifies whether to install Network Watcher Agent extention or not"
  type        = bool
  default     = false
}

variable "boot_diagnostics" {
  description = <<EOF
    A boot_diagnostics block supports the following:
    `storage_account_uri`- The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store
    Boot Diagnostics, including Console Output and Screenshots from the Hypervisor.
    NOTE:
    Passing a null value will utilize a Managed Storage Account to store Boot Diagnostics
    boot_diagnostics = {
      storage_account_uri = null
      }
    EOF
  type = object({
    storage_account_uri = optional(string)
  })
  default = null
}

variable "diagnostic_setting" {
  description = <<EOF
  A mapping of diagnostic setting: 
    `diag_storage_name`: Storage account that should be used for diagnostic settings.
    `diag_storage_primary_access_key`: Diagnostic settings storage account access key.
  diagnostic_setting disabled by default
  EOF
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "post_install_script_path" {
  description = "Path to the script to be run after VM deployment"
  type        = string
  default     = null
}

variable "ad_domain_join" {
  description = <<EOF
  The map of parameters required to join a Azure VM to an AD Domain:
  `domain`: The name of the Active Directory domain to join
  `ou_path`: This is an optional parameter that allows you to join this virtual machine into a specific OU instead of the default Computers container.
  `username`: The user name that is required must have the necessary rights to join computers to an Active Directory Domain
  `username_secret`: The name of a secret where the `username` password is stored
  EOF
  type = object({
    domain          = string
    ou_path         = optional(string)
    username        = string
    username_secret = string
  })
  default = null
}
variable "vm_insights" {
  description = <<EOF
  The map of parameters required for VM Insights:
  `workspace_id`: Log Analytics WorkspaceID (GUID) for the data to be sent to.
  `workspace_key`: Log Analytics Workspace primary or secondary key.
  EOF
  type = object({
    workspace_id  = string
    workspace_key = string
  })
  default = null
}
