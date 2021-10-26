provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

locals {
  tags = {
    product      = "vault"
    tech_contact = "diehl"
    owner        = "tgo"
    region       = "centralus"
  }
  vms = {
    vault01 = "vault01"
    vault02 = "vault02"
    vault03 = "vault03"
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

module "vault_vms" {
  source    = "./modules/vm"
  for_each  = local.vms
  tags      = merge(local.tags, { consul_auto_join = "clam" })
  rg_name   = azurerm_resource_group.vault.name
  subnet_id = azurerm_subnet.vault.id
  vm_name   = each.key
  ssh_key   = data.terraform_remote_state.core.outputs.ssh_key
  # common_name         = each.key
  # organization_name   = "Diehlabs, Inc"
  # ca_key              = tls_private_key.ca
  # ca_cert             = tls_self_signed_cert.ca
  # lb_addresses        = [azurerm_public_ip.vault_lb.ip_address]
  availability_set_id = azurerm_availability_set.vault.id
  # lb_addresses = concat(
  #   azurerm_lb.vault_lb.private_ip_addresses,
  #   [azurerm_public_ip.vault_lb.ip_address]
  # )
  msi = azurerm_user_assigned_identity.vault
}

resource "azurerm_availability_set" "vault" {
  name                         = "avset"
  location                     = azurerm_resource_group.vault.location
  resource_group_name          = azurerm_resource_group.vault.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}
