provider "azurerm" {
  features {}
}

locals {
  tags = {
    product      = "vault"
    tech_contact = "diehl"
    owner        = "tgo"
    region       = "centralus"
  }
}

data "terraform_remote_state" "core" {
  backend = "remote"
  config = {
    organization = "Diehlabs"
    workspaces = {
      name = "k8sauto-core-azure"
    }
  }
}

resource "azurerm_resource_group" "vault" {
  name     = "k8sauto-vault-cluster"
  location = local.tags.region
  tags     = local.tags
}

# resource "azurerm_network_security_group" "vault_vm_nsg" {
#   name                = "vaul-vm-ssh-access"
#   location            = local.tags.region
#   resource_group_name = azurerm_resource_group.vault.name

# dynamic...
#   security_rule {
#     name                       = "SSH"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#   tags = local.tags
# }

# resource "azurerm_network_interface_security_group_association" "vm_ssh" {
#   for_each = module.vault_vms.vms
#   network_interface_id      = each.value.nic_id
#   network_security_group_id = azurerm_network_security_group.vault_vm_nsh.id
# }

resource "azurerm_public_ip" "vault_lb" {
  name                = "PublicIPForLB"
  location            = local.tags.region
  resource_group_name = azurerm_resource_group.vault.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_lb" "vault_lb" {
  name                = "vault_lb"
  location            = local.tags.region
  resource_group_name = azurerm_resource_group.vault.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                          = "vault_lb_pub_ip"
    public_ip_address_id          = azurerm_public_ip.vault_lb.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

resource "azurerm_lb_rule" "vault_lb_rule" {
  resource_group_name            = azurerm_resource_group.vault.name
  loadbalancer_id                = azurerm_lb.vault_lb.id
  name                           = "https"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 8200
  frontend_ip_configuration_name = "vault_lb_pub_ip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.vault_lb_pool.id
  probe_id                       = azurerm_lb_probe.lb_web_probe.id
}

resource "azurerm_lb_probe" "lb_web_probe" {
  resource_group_name = azurerm_resource_group.vault.name
  loadbalancer_id     = azurerm_lb.vault_lb.id
  name                = "vault-health-probe"
  port                = 8200
  protocol            = "Https"
  request_path        = "/v1/sys/health"
}

resource "azurerm_lb_backend_address_pool" "vault_lb_pool" {
  loadbalancer_id = azurerm_lb.vault_lb.id
  name            = "vault-lb-pool"
}

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

resource "azurerm_storage_account" "vault" {
  name                     = "vaultcluster1"
  resource_group_name      = azurerm_resource_group.vault.name
  location                 = azurerm_resource_group.vault.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = local.tags
}

# module "vault_vms" {
#   source = "./modules/vm"
# }
