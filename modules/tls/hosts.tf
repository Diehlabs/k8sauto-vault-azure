resource "tls_private_key" "vm" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "vm" {
  key_algorithm   = tls_private_key.vm.algorithm
  private_key_pem = tls_private_key.vm.private_key_pem
  # dns_names       = each.value.dns_names
  dns_names = var.dns_names
  ip_addresses = concat(
    var.ip_addresses,
    ["127.0.0.1"]
  )
  subject {
    common_name  = "vault00"
    organization = var.organization_name
  }
}

resource "tls_locally_signed_cert" "vm" {
  cert_request_pem      = tls_cert_request.vm.cert_request_pem
  ca_key_algorithm      = tls_private_key.ca.algorithm
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 2400
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
    "server_auth",
  ]
}

# resource "null_resource" "tls_certs" {
#   triggers = {
#     cert_pem = tls_locally_signed_cert.vm.cert_pem
#     key_pem  = sensitive(tls_private_key.vm.private_key_pem)
#   }
#   connection {
#     type        = "ssh"
#     host        = azurerm_public_ip.vm_pub_ip.ip_address
#     user        = "adminuser"
#     private_key = var.ssh_key.private_key_pem
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo mkdir -p /etc/vault/tls",
#       "echo \"${base64encode(tls_locally_signed_cert.vm.cert_pem)}\" | base64 -d | sudo tee /etc/vault/tls/vault-cert.pem",
#       "echo \"${base64encode(tls_private_key.vm.private_key_pem)}\" | base64 -d | sudo tee /etc/vault/tls/vault-key.pem",
#       "echo \"${base64encode(tls_self_signed_cert.ca.cert_pem)}\" | base64 -d | sudo tee /etc/vault/tls/vault-ca.pem",
#       "sudo chown -R root:root /etc/vault/tls",
#       "sudo chmod -R 640 /etc/vault/tls/*"
#     ]
#   }

# }
