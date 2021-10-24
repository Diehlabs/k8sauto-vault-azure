resource "tls_private_key" "vm" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "vm" {
  key_algorithm   = tls_private_key.vm.algorithm
  private_key_pem = tls_private_key.vm.private_key_pem
  dns_names = [
    azurerm_linux_virtual_machine.vm.name,
    azurerm_linux_virtual_machine.vm.computer_name
  ]
  ip_addresses = concat(
    azurerm_linux_virtual_machine.vm.private_ip_addresses,
    [
      azurerm_linux_virtual_machine.vm.public_ip_address,
      "127.0.0.1"
    ]
  )
  subject {
    common_name  = var.common_name
    organization = var.organization_name
  }
}

resource "tls_locally_signed_cert" "vm" {
  cert_request_pem      = tls_cert_request.vm.cert_request_pem
  ca_key_algorithm      = var.ca_key.algorithm
  ca_private_key_pem    = var.ca_key.private_key_pem
  ca_cert_pem           = var.ca_cert.cert_pem
  validity_period_hours = 2400
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
    "server_auth",
  ]
}

# resource "local_file" "cert" {
#   content  = tls_locally_signed_cert.vm.cert_pem
#   filename = "${azurerm_linux_virtual_machine.vm.name}.crt"
# }

# resource "local_file" "key" {
#   sensitive_content = tls_private_key.vm.private_key_pem
#   filename          = "${azurerm_linux_virtual_machine.vm.name}.key"
# }

resource "null_resource" "tls_certs" {
  triggers = {
    cert_pem = tls_locally_signed_cert.vm.cert_pem
    key_pem  = sensitive(tls_private_key.vm.private_key_pem)
  }
  connection {
    type        = "ssh"
    host        = azurerm_public_ip.vm.ip_address
    user        = "adminuser"
    private_key = var.ssh_key.private_key_pem
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo mkdir -p /etc/vault/tls",
  #   ]
  # }
  # provisioner "file" {
  #   content     = tls_locally_signed_cert.vm.cert_pem
  #   destination = "/etc/vault/tls/vault-cert.pem"
  # }
  # provisioner "file" {
  #   content     = tls_private_key.vm.private_key_pem
  #   destination = "/etc/vault/tls/vault-key.pem"
  # }
  # provisioner "file" {
  #   content     = var.ca_cert.cert_pem
  #   destination = "etc/vault/tls/vault-ca.pem"
  # }
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo chown -R root:root /etc/vault/tls",
  #     "sudo chmod -R 600 /etc/vault/tls/*"
  #   ]
  # }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/vault/tls",
      "echo \"${base64encode(tls_locally_signed_cert.vm.cert_pem)}\" | base64 -d | sudo tee /etc/vault/tls/vault-cert.pem",
      "echo \"${base64encode(tls_private_key.vm.private_key_pem)}\" | base64 -d | sudo tee /etc/vault/tls/vault-key.pem",
      "echo \"${base64encode(var.ca_cert.cert_pem)}\" | base64 -d | sudo tee /etc/vault/tls/vault-ca.pem",
      "sudo chown -R root:root /etc/vault/tls",
      "sudo chmod -R 640 /etc/vault/tls/*"
    ]
  }

}

# resource "local_file" "foo" {
#     content     = "${azurerm_public_ip.vm.ip_address}\n${var.ssh_key.private_key_pem}"
#     filename = "${path.module}/foo.bar"
# }
