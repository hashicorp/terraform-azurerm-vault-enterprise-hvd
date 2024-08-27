# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Vault User-Assigned Identity
#------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "vault" {
  name                = "${var.friendly_name_prefix}-vault-msi"
  resource_group_name = local.resource_group_name
  location            = var.location
}

# Add Reader role to prereqs kv
resource "azurerm_role_assignment" "prereqs_kv_reader" {
  scope                = data.azurerm_key_vault.prereqs.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.vault.principal_id
}

# Add access policy to read secrets from prereqs kv
resource "azurerm_key_vault_access_policy" "prereqs_kv_reader" {
  key_vault_id = data.azurerm_key_vault.prereqs.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.vault.principal_id

  secret_permissions = [
    "Get",
  ]

  key_permissions = [
    "Get",
    "List",
    "Encrypt",
    "Decrypt",
    "WrapKey",
    "UnwrapKey",
  ]
}

# Add Reader role to resource group (cloud auto-join)
resource "azurerm_role_assignment" "resource_group_reader" {
  scope                = local.resource_group_id
  principal_id         = azurerm_user_assigned_identity.vault.principal_id
  role_definition_name = "Reader"
}

#------------------------------------------------------------------------------
# VMSS Disk Encryption Set
#------------------------------------------------------------------------------
resource "azurerm_role_assignment" "vault_vmss_disk_encryption_set_reader" {
  count = var.vm_disk_encryption_set_name != null && var.vm_disk_encryption_set_rg != null ? 1 : 0

  scope                = data.azurerm_disk_encryption_set.vmss[0].id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.vault.principal_id
}
