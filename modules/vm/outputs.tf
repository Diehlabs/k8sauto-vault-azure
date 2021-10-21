output "ip_address" {
  value = azurerm_network_interface.vm.private_ip_addresses[0]
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.vm.name
}
