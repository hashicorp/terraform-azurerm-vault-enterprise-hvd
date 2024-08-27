# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# AzureRM Client Config
#------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

# data source for prereqs kv containing bootstrap secrets and unseal key
data "azurerm_key_vault" "prereqs" {
  name                = var.prereqs_keyvault_name
  resource_group_name = var.prereqs_keyvault_rg_name
}

data "azurerm_disk_encryption_set" "vmss" {
  count = var.vm_disk_encryption_set_name != null && var.vm_disk_encryption_set_rg != null ? 1 : 0

  name                = var.vm_disk_encryption_set_name
  resource_group_name = var.vm_disk_encryption_set_rg
}
