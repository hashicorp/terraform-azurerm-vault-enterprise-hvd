# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Public IP (optional)
#------------------------------------------------------------------------------
resource "azurerm_public_ip" "vault_lb" {
  count = var.create_lb == true && var.lb_is_internal == false ? 1 : 0

  name                = "${var.friendly_name_prefix}-vault-lb-ip"
  resource_group_name = local.resource_group_name
  location            = var.location
  zones               = var.availability_zones
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = merge(
    { "Name" = "${var.friendly_name_prefix}-vault-lb-ip" },
    var.common_tags
  )
}

#------------------------------------------------------------------------------
# Azure Load Balancer
#------------------------------------------------------------------------------
resource "azurerm_lb" "vault" {
  count = var.create_lb == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-vault-lb"
  resource_group_name = local.resource_group_name
  location            = var.location
  sku                 = "Standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name                 = "vault-frontend-${local.lb_frontend_name_suffix}"
    zones                = var.lb_is_internal == true ? var.availability_zones : null
    public_ip_address_id = var.lb_is_internal == false ? azurerm_public_ip.vault_lb[0].id : null
    subnet_id            = var.lb_is_internal == true ? var.lb_subnet_id : null
    private_ip_address_allocation = (var.lb_is_internal == true ?
      (var.lb_private_ip != null ? "Static" : "Dynamic") :
    null)
    private_ip_address = var.lb_is_internal == true && var.lb_private_ip != null ? var.lb_private_ip : null
  }

  tags = merge(
    { "Name" = "${var.friendly_name_prefix}-vault-lb" },
    var.common_tags
  )
}

resource "azurerm_lb_backend_address_pool" "vault_servers" {
  count = var.create_lb == true ? 1 : 0

  name            = "${var.friendly_name_prefix}-vault-backend"
  loadbalancer_id = azurerm_lb.vault[0].id
}

# resource "azurerm_lb_backend_address_pool" "vault_servers_443" {
#   count = var.create_lb == true ? 1 : 0

#   name            = "${var.friendly_name_prefix}-vault-backend-https"
#   loadbalancer_id = azurerm_lb.vault[0].id
# }

resource "azurerm_lb_probe" "vault" {
  count = var.create_lb == true ? 1 : 0

  name                = "vault-lb-probe"
  loadbalancer_id     = azurerm_lb.vault[0].id
  protocol            = "Https"
  port                = 8200
  request_path        = "/v1/sys/health?perfstandbyok=1&uninitcode=200&drsecondarycode=200"
  interval_in_seconds = 15
}

# TODO: Resolve error to support listening on both 8200 and 443
# Load Balancing Rule Name: "sunny-vault-lb-rule-443"): performing CreateOrUpdate: unexpected status 400 (400 Bad Request) with error: RulesUseSameBackendPortProtocolAndPool: 
# Load balancing rules /.../sunny-vault-lb-rule-8200 and /.../sunny-vault-lb-rule-443 with floating IP disabled use the same protocol Tcp and backend port 8200, and must not be used with the same backend address pool /.../sunny-vault-backend.
#
# LB rules need to map 1:1. Probable solution is to add a second API listener on 8443 then have a 443->8443 LB rule
#
# resource "azurerm_lb_rule" "vault_443" {
#   count = var.create_lb == true ? 1 : 0

#   name                           = "${var.friendly_name_prefix}-vault-lb-rule-443"
#   loadbalancer_id                = azurerm_lb.vault[0].id
#   # probe_id                       = azurerm_lb_probe.vault[0].id
#   protocol                       = "Tcp"
#   frontend_ip_configuration_name = azurerm_lb.vault[0].frontend_ip_configuration[0].name
#   frontend_port                  = 443
#   backend_address_pool_ids       = [azurerm_lb_backend_address_pool.vault_servers_443[0].id]
#   backend_port                   = 8200
# }

resource "azurerm_lb_rule" "vault_8200" {
  count = var.create_lb == true ? 1 : 0

  name                           = "${var.friendly_name_prefix}-vault-lb-rule-8200"
  loadbalancer_id                = azurerm_lb.vault[0].id
  probe_id                       = azurerm_lb_probe.vault[0].id
  protocol                       = "Tcp"
  frontend_ip_configuration_name = azurerm_lb.vault[0].frontend_ip_configuration[0].name
  frontend_port                  = 8200
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.vault_servers[0].id]
  backend_port                   = 8200
}