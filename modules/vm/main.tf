resource "azurerm_network_interface" "vm" {
  name                = "${var.vm_name}-nic"
  location            = var.tags.region
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
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
    public_key = var.ssh_public_key
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

  tags = var.tags
}

resource "azurerm_public_ip" "vm" {
  name                = "${var.vm_name}-pubip"
  location            = var.tags.region
  resource_group_name = var.rg_name
  allocation_method   = "Static"

  tags = var.tags
}
