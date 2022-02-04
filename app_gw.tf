resource "azurerm_subnet" "vault_agw" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.vault.name
  virtual_network_name = azurerm_virtual_network.vault.name
  address_prefixes     = ["192.168.50.240/28"]
}

resource "azurerm_public_ip" "vault_agw" {
  name                = "vault-agw"
  resource_group_name = azurerm_resource_group.vault.name
  location            = azurerm_resource_group.vault.location
  allocation_method   = "Dynamic"
}

#&nbsp;since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vault.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vault.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vault.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vault.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vault.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vault.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.vault.name}-rdrcfg"
}

resource "azurerm_application_gateway" "vault" {
  name                = "hashivault-appgateway"
  resource_group_name = azurerm_resource_group.vault.name
  location            = azurerm_resource_group.vault.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 3
  }

  gateway_ip_configuration {
    name      = "hashivault-gateway-ip-configuration"
    subnet_id = azurerm_subnet.vault_agw.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.vault_agw.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 8200
    protocol              = "Https"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  probe {
    name                                      = "syshealth"
    protocol                                  = "https"
    interval                                  = 30
    timeout                                   = 300
    path                                      = "/v1/sys/health"
    pick_host_name_from_backend_http_settings = true
    match {
      body        = "*"
      status_code = 200
    }
  }
}

resource "azurerm_dns_a_record" "vault" {
  name                = "hashivault"
  zone_name           = "diehlabs.com"
  resource_group_name = "diehlabs-dns"
  ttl                 = 300
  records             = [azurerm_public_ip.vault_agw.ip_address]
  tags                = local.tags
}
