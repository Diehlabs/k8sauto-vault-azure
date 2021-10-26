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

resource "azurerm_network_security_group" "vault_vm_nsg" {
  name                = "vault-nsg"
  location            = local.tags.region
  resource_group_name = azurerm_resource_group.vault.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Vault"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8200"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Consul"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = local.tags
}

resource "azurerm_network_interface_security_group_association" "vm_ssh" {
  for_each = { for vm in module.vault_vms :
    vm.vm_name => vm.nic_id
  }
  network_interface_id      = each.value
  network_security_group_id = azurerm_network_security_group.vault_vm_nsg.id
}
