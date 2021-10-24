resource "azurerm_virtual_network" "vault" {
  name                = "vault-vnet"
  address_space       = ["192.168.50.0/24"]
  location            = azurerm_resource_group.vault.location
  resource_group_name = azurerm_resource_group.vault.name
}

resource "azurerm_subnet" "vault" {
  name                 = "vault-cluster"
  resource_group_name  = azurerm_resource_group.vault.name
  virtual_network_name = azurerm_virtual_network.vault.name
  address_prefixes     = ["192.168.50.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}
