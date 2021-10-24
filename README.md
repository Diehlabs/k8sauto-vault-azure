Creates a Vault cluster in Azure.

Requires AzureRM provider SPN credentials be supplied as env vars:
* ARM_CLIENT_ID
* ARM_CLIENT_SECRET
* ARM_SUBSCRIPTION_ID
* ARM_TENANT_ID

Nodes will auto join using NIC tags.

Nodes will auto unseal using AKV.

VMs will use an MSI to access the AKV. It can take some time before the VM is able to access the AKV, so normally the cluster will be non operationl for a while upon creation.
