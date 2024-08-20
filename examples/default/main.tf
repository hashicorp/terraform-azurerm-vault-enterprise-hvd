terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.101"
    }
  }
}

provider "azurerm" {
  features {}
}

module "default_example" {
  source = "../../"

  #------------------------------------------------------------------------------
  # Common
  #------------------------------------------------------------------------------
  friendly_name_prefix  = var.friendly_name_prefix
  location              = var.location
  create_resource_group = var.create_resource_group
  resource_group_name   = var.resource_group_name
  vault_fqdn            = var.vault_fqdn

  #------------------------------------------------------------------------------
  # Networking
  #------------------------------------------------------------------------------
  vnet_id         = var.vnet_id
  vault_subnet_id = var.vault_subnet_id

  #------------------------------------------------------------------------------
  # Azure Key Vault installation secrets and unseal key
  #------------------------------------------------------------------------------
  prereqs_keyvault_rg_name               = var.prereqs_keyvault_rg_name
  prereqs_keyvault_name                  = var.prereqs_keyvault_name
  vault_license_keyvault_secret_id       = var.vault_license_keyvault_secret_id
  vault_tls_cert_keyvault_secret_id      = var.vault_tls_cert_keyvault_secret_id
  vault_tls_privkey_keyvault_secret_id   = var.vault_tls_privkey_keyvault_secret_id
  vault_tls_ca_bundle_keyvault_secret_id = var.vault_tls_ca_bundle_keyvault_secret_id

  vault_seal_azurekeyvault_vault_name      = var.vault_seal_azurekeyvault_vault_name
  vault_seal_azurekeyvault_unseal_key_name = var.vault_seal_azurekeyvault_unseal_key_name

  #------------------------------------------------------------------------------
  # Compute
  #------------------------------------------------------------------------------
  vm_ssh_public_key = file(var.vm_ssh_public_key_path)
  vmss_vm_count     = 3
  vm_sku            = "Standard_D2s_v5"
}
