# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

locals {
  lb_frontend_name_suffix = var.lb_is_internal == true ? "internal" : "external"

  resource_group_name = (
    var.create_resource_group == true ?
    azurerm_resource_group.vault[0].name : data.azurerm_resource_group.vault[0].name
  )

  resource_group_id = (
    var.create_resource_group == true ?
    azurerm_resource_group.vault[0].id : data.azurerm_resource_group.vault[0].id
  )

  vault_hostname_public  = var.create_vault_public_dns_record == true && var.public_dns_zone_name != null ? trimsuffix(substr(var.vault_fqdn, 0, length(var.vault_fqdn) - length(var.public_dns_zone_name) - 1), ".") : var.vault_fqdn
  vault_hostname_private = var.create_vault_private_dns_record == true && var.private_dns_zone_name != null ? trim(split(var.private_dns_zone_name, var.vault_fqdn)[0], ".") : var.vault_fqdn
}
