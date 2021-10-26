resource "azurerm_network_interface" "vm" {
  name                = "${var.vm_name}-nic"
  location            = var.tags.region
  resource_group_name = var.rg_name
  ip_configuration {
    name                          = "default"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pub_ip.id
  }
  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  #############################################################
  # availability_set_id             = var.availability_set_id #
  #############################################################
  name                            = var.vm_name
  location                        = var.tags.region
  resource_group_name             = var.rg_name
  size                            = "Standard_B1ls"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_key.public_key_openssh
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

  identity {
    type         = "UserAssigned"
    identity_ids = [var.msi.id]
  }

  tags = var.tags
}

resource "azurerm_public_ip" "vm_pub_ip" {
  name                = "${var.vm_name}-pubip"
  location            = var.tags.region
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
