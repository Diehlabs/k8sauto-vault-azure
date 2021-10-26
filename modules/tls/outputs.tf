# resource "local_file" "cert" {
#   content  = tls_locally_signed_cert.vm.cert_pem
#   filename = "${azurerm_linux_virtual_machine.vm.name}.crt"
# }

# resource "local_file" "key" {
#   sensitive_content = tls_private_key.vm.private_key_pem
#   filename          = "${azurerm_linux_virtual_machine.vm.name}.key"
# }

# output "certs" {
#   value = {
#     for host, vals in var.hosts_data :
#     host => {
#       # key  = tls_private_key.vm[host]
#       key = tls_private_key.vm
#       cert = tls_locally_signed_cert.vm[host]
#     }
#   }
# }

output "cert" {
  value = tls_locally_signed_cert.vm.cert_pem
}

output "key" {
  value = tls_private_key.vm.private_key_pem
}

output "ca_pem" {
  value = tls_self_signed_cert.ca.cert_pem
}
