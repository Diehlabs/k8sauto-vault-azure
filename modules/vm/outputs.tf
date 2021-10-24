output "ip_address" {
  value = azurerm_network_interface.vm.private_ip_addresses[0]
}

output "public_ip" {
  value = azurerm_public_ip.vm.ip_address
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.vm.name
}

output "nic_id" {
  value = azurerm_network_interface.vm.id
}

output "tls_cert_key" {
  value     = tls_private_key.vm
  sensitive = true
}

output "tls_cert" {
  value     = tls_locally_signed_cert.vm
  sensitive = true
}

output "msi" {
  value = azurerm_linux_virtual_machine.vm.identity
}
