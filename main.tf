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
    location     = "centralus"
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
  location = local.tags.location
  tags     = local.tags
}

module "vault_vms" {
  source    = "github.com/Diehlabs/terraform-azurerm-linuxvm?ref=v0.0.3"
  for_each  = local.vms
  tags      = merge(local.tags, { consul_auto_join = "clam" })
  rg_name   = azurerm_resource_group.vault.name
  subnet_id = azurerm_subnet.vault.id
  vm_name   = each.key
  ssh_key   = data.terraform_remote_state.core.outputs.ssh_key.public_key_openssh
  #availability_set_id = azurerm_availability_set.vault.id
}
