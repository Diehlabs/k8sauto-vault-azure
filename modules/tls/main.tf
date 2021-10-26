resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm         = tls_private_key.ca.algorithm
  private_key_pem       = tls_private_key.ca.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = 2400
  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]

  subject {
    common_name  = var.ca_common_name
    organization = var.organization_name
  }
}
