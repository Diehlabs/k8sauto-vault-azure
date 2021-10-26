# module "tls" {
#   source = "./modules/tls"
#   hosts_data = {
#     for vm in module.vault_vms :
#     (vm.vm_name) => {
#       dns_names    = tolist([vm.computer_name, vm.vm_name])
#       ip_addresses = concat(
#           vm.ip_addresses,
#           [azurerm_public_ip.vault_lb.ip_address]
#       )
#     }
#   }
# }

module "tls" {
  source = "./modules/tls"
  dns_names = [
    for k, v in local.vms : k
  ]
  ip_addresses = [
    for name in local.vms : module.vault_vms[name].ip_addresses
  ]
}
