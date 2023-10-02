variable "type" {
  type        = string
  description = "Type of resosurce being created"
  validation {
    condition     = contains(["vm", "share", "storage"], var.type)
    error_message = "The type must be equal to one of the values: vm, share, storage!"
  }
}

variable "backup_resource_id" {
  type        = string
  description = "The ID of the source resource to be backed up (VM or storage account)"
}

variable "policy_id" {
  type        = string
  description = "Specifies the ID of the Backup Policy"
  default     = null
}

variable "share" {
  type        = string
  description = "The Azure Share name for backup"
  default     = null
}
variable "vault_name" {
  type        = string
  description = "Specifies the name of the Recovery Services Vault"
}

variable "vault_rg" {
  type        = string
  description = "The name of the resource group in which the Recovery Services Vault resides"
}
