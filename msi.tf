# resource "azurerm_role_definition" "vault" {
#   name        = "vaul-consul-auto-join"
#   scope       = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
#   description = "This is a custom role created via Terraform"

#   permissions {
#     actions     = ["Microsoft.Network/networkInterfaces/read"]
#     not_actions = []
#   }

#   assignable_scopes = [
#     "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
#   ]
# }

# resource "azurerm_role_assignment" "vault" {
#   scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
#   # role_definition_name = azurerm_role_definition.vault.name
#   role_definition_name = "Reader"
#   principal_id         = azurerm_user_assigned_identity.vault.principal_id
# }

resource "azurerm_user_assigned_identity" "vault" {
  resource_group_name = azurerm_resource_group.vault.name
  location            = azurerm_resource_group.vault.location
  name                = "vault-cluster"
  tags = {
    consul_auto_join = "clam"
  }
}
