resource "azurerm_key_vault" "vault" {
  depends_on = [
    azurerm_user_assigned_identity.vault
  ]
  name                = "k8sauto-keyvault"
  location            = azurerm_resource_group.vault.location
  resource_group_name = azurerm_resource_group.vault.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # enable virtual machines to access this key vault.
  enabled_for_deployment = true

  sku_name = "standard"

  tags = local.tags

  # access policy for the vm MSIs
  #   dynamic "access_policy" {
  #     for_each = { for vm in module.vault_vms :
  #       vm.msi[0].principal_id => vm.msi[0].tenant_id
  #     }
  #     content {
  #       tenant_id = access_policy.value
  #       object_id = access_policy.key

  #       key_permissions = [
  #         "get",
  #         "wrapKey",
  #         "unwrapKey",
  #       ]
  #     }
  #   }
  access_policy {
    tenant_id = azurerm_user_assigned_identity.vault.tenant_id
    object_id = azurerm_user_assigned_identity.vault.principal_id

    key_permissions = [
      "get",
      "wrapKey",
      "unwrapKey",
    ]
  }

  # access policy for the user that is currently running terraform.
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
      "list",
      "create",
      "delete",
      "update",
      "purge",
    ]
  }

  # TODO does this really need to be so broad? can it be limited to the vault vm?
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

# hashicorp vault will use this azurerm_key_vault_key to wrap/encrypt its master key.
resource "azurerm_key_vault_key" "generated" {
  name         = "hashivault"
  key_vault_id = azurerm_key_vault.vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "wrapKey",
    "unwrapKey",
  ]
}
