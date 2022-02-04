# k8sauto-vault-azure
Creates a Vault cluster in Azure. Implements Raft HA storage, auto join, auto unseal.

Requires AzureRM provider SPN credentials be supplied as env vars:
* ARM_CLIENT_ID
* ARM_CLIENT_SECRET
* ARM_SUBSCRIPTION_ID
* ARM_TENANT_ID

Nodes will auto join using NIC tags.

Nodes will auto unseal using AKV.

VMs will use an MSI to access the AKV. It can take some time before the VM is able to access the AKV, so normally the cluster will be non operationl for a while upon creation.

Because files for ansible are generated as local_file resources (inventory.yml, etc), the plan will always show changes in a pipeline. Ideally this pipeline should call another pipeline and/or output the inventory and other required data instead.

Running Vault commands - since we are using self signed TLS certificates, remember to use the -tls-skip-verify option with all Vault CLI commands.

Run `terraform state show azurerm_public_ip.vault_lb` to get the public IP address of the load balancer.

## Overview
1. Create TLS certificates
2. Create Azure Key Vault
    * Add certs to AKV
    * Create master key for Hashi Vault in AKV
3. Create a user assigned identity
    * Grant appropriate rights
4. Create AGW
    * Distribute TLS certificate
5. Create VMs
    * Use previsouly created identity for the VMs
6. Trigger Ansible pipeline
    * Distribute cluster node certificates
    * Configure cluster nodes


Notes:
How to access AKV from a VM with a managed identity:
* akvt=`curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H "Metadata: true"`
* curl https://diehlabs-keyvault.vault.azure.net/keys?api-version=7.2 -H "Authorization:Bearer ${akvt}"

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 2.77.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.1.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 2.81.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.1.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vault_vms"></a> [vault\_vms](#module\_vault\_vms) | github.com/Diehlabs/terraform-azurerm-linuxvm | v0.0.3 |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_dns_a_record.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_key_vault_certificate.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) | resource |
| [azurerm_network_interface_security_group_association.vm_ssh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.vault_subnet_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.vault_vm_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.vault_agw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.vault_agw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.vault_subnet_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [local_file.ansible_inventory](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.rsa_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.ansible](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [terraform_remote_state.core](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ansible_inventory"></a> [ansible\_inventory](#output\_ansible\_inventory) | n/a |
<!-- END_TF_DOCS -->
