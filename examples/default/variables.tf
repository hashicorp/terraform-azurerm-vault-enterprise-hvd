# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix for uniquely naming Azure resources."

  validation {
    condition     = can(regex("^[[:alnum:]]+$", var.friendly_name_prefix)) && length(var.friendly_name_prefix) < 13
    error_message = "Value can only contain alphanumeric characters and must be less than 13 characters."
  }
}

variable "location" {
  type        = string
  description = "Azure region for this Vault deployment."

  validation {
    condition     = contains(["eastus", "westus", "centralus", "eastus2", "westus2", "westus3", "westeurope", "northeurope", "southeastasia", "eastasia", "australiaeast", "australiasoutheast", "uksouth", "ukwest", "canadacentral", "canadaeast", "southindia", "centralindia", "westindia", "japaneast", "japanwest", "koreacentral", "koreasouth", "francecentral", "southafricanorth", "uaenorth", "brazilsouth", "switzerlandnorth", "germanywestcentral", "norwayeast", "westcentralus"], var.location)
    error_message = "The location specified is not a valid Azure region."
  }
}

variable "create_resource_group" {
  type        = bool
  description = "Boolean to create a new Resource Group for this Vault deployment."
  default     = true
}

variable "resource_group_name" {
  type        = string
  description = "Name of Resource Group to use for Vault cluster resources"
  default     = "example-vault"
}

variable "vault_fqdn" {
  type        = string
  description = "Fully qualified domain name of the Vault cluster. This name __must__ match a SAN entry in the TLS server certificate."
}

variable "vnet_id" {
  type        = string
  description = "VNet ID where Vault resources will reside."
}

variable "vault_subnet_id" {
  type        = string
  description = "Subnet ID for Vault server VMs."
}

variable "prereqs_keyvault_name" {
  type        = string
  description = "Name of the 'prereqs' Key Vault to use for prereqs Vault deployment."
}

variable "prereqs_keyvault_rg_name" {
  type        = string
  description = "Name of the Resource Group where the 'prereqs' Key Vault resides."
}

variable "vault_license_keyvault_secret_id" {
  type        = string
  description = "ID of Key Vault secret containing Vault license."
}

variable "vault_tls_cert_keyvault_secret_id" {
  type        = string
  description = "ID of Key Vault secret containing Vault TLS certificate."
}

variable "vault_tls_privkey_keyvault_secret_id" {
  type        = string
  description = "ID of Key Vault secret containing Vault TLS private key."
}

variable "vault_tls_ca_bundle_keyvault_secret_id" {
  type        = string
  description = "ID of Key Vault secret containing Vault TLS custom CA bundle."
  nullable    = true
}

variable "vault_seal_azurekeyvault_vault_name" {
  type        = string
  description = "Name of the Azure Key Vault vault holding Vault's unseal key"
  nullable    = true
}

variable "vault_seal_azurekeyvault_unseal_key_name" {
  type        = string
  description = "Name of the Azure Key Vault key to use for auto-unseal"
  nullable    = true
}

variable "vm_ssh_public_key_path" {
  type        = string
  description = "File system path to the SSH public key for VMs in VMSS."
  default     = null
}
