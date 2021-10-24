# resource "azurerm_public_ip" "vault_lb" {
#   name                = "vault-lb-public-ip"
#   location            = local.tags.region
#   resource_group_name = azurerm_resource_group.vault.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   tags                = local.tags
# }

# resource "azurerm_lb" "vault_lb" {
#   name                = "vault-lb"
#   location            = local.tags.region
#   resource_group_name = azurerm_resource_group.vault.name
#   sku                 = "Standard"
#   frontend_ip_configuration {
#     name                          = "vault-lb-pub-ip"
#     public_ip_address_id          = azurerm_public_ip.vault_lb.id
#     private_ip_address_allocation = "Dynamic"
#   }

#   tags = local.tags
# }

# # resource "azurerm_lb_rule" "vault_lb_rule" {
# #   resource_group_name            = azurerm_resource_group.vault.name
# #   loadbalancer_id                = azurerm_lb.vault_lb.id
# #   name                           = "https"
# #   protocol                       = "Tcp"
# #   frontend_port                  = 443
# #   backend_port                   = 8200
# #   frontend_ip_configuration_name = "vault-lb-pub-ip"
# #   backend_address_pool_id        = azurerm_lb_backend_address_pool.vault_lb_pool.id
# #   probe_id                       = azurerm_lb_probe.lb_web_probe.id
# # }

# resource "azurerm_lb_probe" "lb_web_probe" {
#   resource_group_name = azurerm_resource_group.vault.name
#   loadbalancer_id     = azurerm_lb.vault_lb.id
#   name                = "vault-health-probe"
#   port                = 8200
#   protocol            = "Https"
#   request_path        = "/v1/sys/health"
# }

# resource "azurerm_lb_backend_address_pool" "vault_lb_pool" {
#   loadbalancer_id = azurerm_lb.vault_lb.id
#   name            = "vault-lb-pool"
# }

# resource "azurerm_lb_nat_rule" "vault" {
#   resource_group_name            = azurerm_resource_group.vault.name
#   loadbalancer_id                = azurerm_lb.vault_lb.id
#   name                           = "vault-api"
#   protocol                       = "Tcp"
#   frontend_port                  = 443
#   backend_port                   = 8200
#   frontend_ip_configuration_name = "vault-lb-pub-ip"
# }

module "loadbalancer" {
  source              = "Azure/loadbalancer/azurerm"
  version             = "3.4.0"
  resource_group_name = azurerm_resource_group.vault.name
  lb_sku              = "Standard"
  pip_sku             = "Standard"
  name                = "vault-cluster-lb"
  pip_name            = "vault-lb-pub-ip"

  lb_port = {
    https = ["8200", "Tcp", "8200"]
  }

  lb_probe = {
    http = ["Https", "8200", "/v1/sys/health"]
  }

  tags = local.tags
  depends_on = [
    azurerm_resource_group.vault
  ]
}
