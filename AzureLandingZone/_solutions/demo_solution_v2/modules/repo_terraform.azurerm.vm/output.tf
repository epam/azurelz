output "windows_vm_id" {
  description = "The ID of the windows virtual machine"
  value       = var.vm_guest_os == "windows" ? azurerm_windows_virtual_machine.vm_windows[0].id : null
}

output "windows_vm_private_ip_addresses" {
  description = "The Private ip of the windows virtual machine"
  value       = var.vm_guest_os == "windows" ? azurerm_windows_virtual_machine.vm_windows[0].private_ip_addresses : null
}

output "windows_vm_identity" {
  description = "The ID of the identity assigned to the VM"
  value       = var.vm_guest_os == "windows" ? azurerm_windows_virtual_machine.vm_windows[0].identity[0].principal_id : null
}

output "linux_vm_id" {
  description = "The ID of the linux virtual machine"
  value       = var.vm_guest_os == "linux" ? azurerm_linux_virtual_machine.vm_linux[0].id : null
}

output "linux_vm_private_ip_addresses" {
  description = "The Private ip of the linux virtual machine"
  value       = var.vm_guest_os == "linux" ? azurerm_linux_virtual_machine.vm_linux[0].private_ip_addresses : null
}

output "linux_vm_identity" {
  description = "The ID of the identity assigned to the VM"
  value       = var.vm_guest_os == "linux" ? azurerm_linux_virtual_machine.vm_linux[0].identity[0].principal_id : null
}
