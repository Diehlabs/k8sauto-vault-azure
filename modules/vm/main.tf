resource "azurerm_network_interface" "vm" {
  name                = "internal"
  location            = azurerm_resource_group.aks_jump.location
  resource_group_name = azurerm_resource_group.aks_jump.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.core.outputs.subnets["control"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }

  tags = local.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  location                        = var.location
  resource_group_name             = var.rg_name
  size                            = "Standard_B1ls"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = data.terraform_remote_state.core.outputs.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = local.tags
}

resource "azurerm_public_ip" "vm" {
  name                = "jump-box-pip"
  location            = azurerm_resource_group.aks_jump.location
  resource_group_name = azurerm_resource_group.aks_jump.name
  allocation_method   = "Static"

  tags = local.tags
}
