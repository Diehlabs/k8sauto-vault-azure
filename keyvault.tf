data "azurerm_key_vault" "vault" {
  name                = "diehlabs-keyvault"
  resource_group_name = "diehlabs-root"
}

locals {
  dns_names = [
    for k, v in local.vms : k
  ]
  ip_addresses = [
    for name in local.vms : module.vault_vms[name].ip_addresses
  ]
}

resource "azurerm_key_vault_certificate" "vault" {
  name         = "vault-cluster"
  key_vault_id = azurerm_key_vault.vault.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pem-file"
    }

    x509_certificate_properties {
      #   Server Authentication = 1.3.6.1.5.5.7.3.1
      #   Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1", "1.3.6.1.5.5.7.3.2"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = concat(
          ["127.0.0.1"],
          local.dns_names,
          local.ip_addresses
        )
      }

      subject            = "CN=hcv"
      validity_in_months = 12
    }
  }
}
