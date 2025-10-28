# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------
variable "resource_group_name" {
  type        = string
  description = "Name of Resource Group to use for Vault cluster resources"
  default     = "vault-ent-rg"
}

variable "create_resource_group" {
  type        = bool
  description = "Boolean to create a new Resource Group for this Vault deployment."
  default     = true
}

variable "location" {
  type        = string
  description = "Azure region for this Vault deployment."

  validation {
    condition     = contains(["eastus", "westus", "centralus", "eastus2", "westus2", "westus3", "westeurope", "northeurope", "southeastasia", "eastasia", "australiaeast", "australiasoutheast", "uksouth", "ukwest", "canadacentral", "canadaeast", "southindia", "centralindia", "westindia", "japaneast", "japanwest", "koreacentral", "koreasouth", "francecentral", "southafricanorth", "uaenorth", "brazilsouth", "switzerlandnorth", "germanywestcentral", "norwayeast", "westcentralus"], var.location)
    error_message = "The location specified is not a valid Azure region."
  }
}

variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix for uniquely naming Azure resources."

  validation {
    condition     = can(regex("^[[:alnum:]]+$", var.friendly_name_prefix)) && length(var.friendly_name_prefix) < 13
    error_message = "Value can only contain alphanumeric characters and must be less than 13 characters."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for taggable Azure resources."
  default     = {}
}

variable "availability_zones" {
  type        = set(string)
  description = "List of Azure Availability Zones to spread Vault resources across."
  default     = ["1", "2", "3"]

  validation {
    condition     = alltrue([for az in var.availability_zones : contains(["1", "2", "3"], az)])
    error_message = "Availability zone must be one of, or a combination of '1', '2', '3'."
  }
}

variable "is_govcloud_region" {
  type        = bool
  description = "Boolean indicating whether this Vault deployment is in an Azure Government Cloud region."
  default     = false
}

#------------------------------------------------------------------------------
# prereqs
#------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------
# Vault configuration settings
#------------------------------------------------------------------------------
variable "vault_fqdn" {
  type        = string
  description = "Fully qualified domain name of the Vault cluster. This name __must__ match a SAN entry in the TLS server certificate."
}

variable "vault_version" {
  type        = string
  description = "Version of Vault to install."
  default     = "1.17.3+ent"
}

variable "vault_disable_mlock" {
  type        = bool
  description = "Boolean to disable mlock. Mlock should be disabled when using Raft integrated storage."
  default     = true
}

variable "vault_enable_ui" {
  type        = bool
  description = "Boolean to enable Vault's web UI"
  default     = true
}

variable "vault_default_lease_ttl_duration" {
  type        = string
  description = "The default lease TTL expressed as a time duration in hours, minutes and/or seconds (e.g. `4h30m10s`)"
  default     = "1h"

  validation {
    condition     = can(regex("^([[:digit:]]+h)*([[:digit:]]+m)*([[:digit:]]+s)*$", var.vault_default_lease_ttl_duration))
    error_message = "Value must be a combination of hours (h), minutes (m) and/or seconds (s). e.g. `4h30m10s`"
  }
}

variable "vault_max_lease_ttl_duration" {
  type        = string
  description = "The max lease TTL expressed as a time duration in hours, minutes and/or seconds (e.g. `4h30m10s`)"
  default     = "768h"

  validation {
    condition     = can(regex("^([[:digit:]]+h)*([[:digit:]]+m)*([[:digit:]]+s)*$", var.vault_max_lease_ttl_duration))
    error_message = "Value must be a combination of hours (h), minutes (m) and/or seconds (s). e.g. `4h30m10s`"
  }
}

variable "vault_port_api" {
  type        = number
  description = "TCP port for Vault API listener"
  default     = 8200
}

variable "vault_port_cluster" {
  type        = number
  description = "TCP port for Vault cluster address"
  default     = 8201
}

variable "vault_telemetry_config" {
  type        = map(string)
  description = "Enable telemetry for Vault"
  default     = null

  validation {
    condition     = var.vault_telemetry_config == null || can(tomap(var.vault_telemetry_config))
    error_message = "Telemetry config must be provided as a map of key-value pairs."
  }
}

variable "vault_tls_disable_client_certs" {
  type        = bool
  description = "Disable Vault UI prompt for client certificates"
  default     = false
}

variable "vault_tls_require_and_verify_client_cert" {
  type        = bool
  description = "Require and verify client certs on API requests"
  default     = false
}

variable "vault_seal_type" {
  type        = string
  description = ""
  default     = "azurekeyvault"
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

variable "vault_raft_performance_multiplier" {
  description = "Raft performance multiplier value. Defaults to 5, which is the default Vault value."
  type        = number
  default     = 5

  validation {
    condition     = var.vault_raft_performance_multiplier >= 1 && var.vault_raft_performance_multiplier <= 10
    error_message = "Raft performance multiplier must be an integer between 1 and 10."
  }

  validation {
    condition     = var.vault_raft_performance_multiplier == floor(var.vault_raft_performance_multiplier)
    error_message = "Raft performance multiplier must be an integer."
  }
}
#------------------------------------------------------------------------------
# System paths and settings
#------------------------------------------------------------------------------
variable "additional_package_names" {
  type        = set(string)
  description = "List of additional repository package names to install"
  default     = []
}

variable "systemd_dir" {
  type        = string
  description = "Path to systemd directory for unit files"
  default     = "/lib/systemd/system"
}

variable "vault_dir_bin" {
  type        = string
  description = "Path to install Vault Enterprise binary"
  default     = "/usr/bin"
}

variable "vault_dir_config" {
  type        = string
  description = "Path to install Vault Enterprise binary"
  default     = "/etc/vault.d"
}

variable "vault_dir_home" {
  type        = string
  description = "Path to hold data, plugins and license directories"
  default     = "/opt/vault"
}

variable "vault_dir_logs" {
  type        = string
  description = "Path to hold Vault file audit device logs"
  default     = "/var/log/vault"
}

variable "vault_plugin_urls" {
  type        = list(string)
  default     = []
  description = "(optional list) List of Vault plugin fully qualified URLs (example [\"https://releases.hashicorp.com/terraform-provider-oraclepaas/1.5.3/terraform-provider-oraclepaas_1.5.3_linux_amd64.zip\"] for deployment to Vault plugins directory)"
  # validation {
  #   condition     = "is url"
  #   error_message = "value is not url"
  # }
}

variable "vault_user_name" {
  type        = string
  description = "Name of system user to own Vault files and processes"
  default     = "vault"
}

variable "vault_group_name" {
  type        = string
  description = "Name of group to own Vault files and processes"
  default     = "vault"
}

#------------------------------------------------------------------------------
# Networking
#------------------------------------------------------------------------------
variable "vnet_id" {
  type        = string
  description = "VNet ID where Vault resources will reside."
}

variable "create_lb" {
  type        = bool
  description = "Boolean to create an Azure Load Balancer for Vault."
  default     = true
}

variable "lb_subnet_id" {
  type        = string
  description = "Subnet ID for Azure load balancer."
  default     = null
}

variable "lb_is_internal" {
  type        = bool
  description = "Boolean to create an internal or external Azure Load Balancer for Vault."
  default     = false
}

variable "lb_private_ip" {
  type        = string
  description = "Private IP address for internal Azure Load Balancer. Only valid when `lb_is_internal` is `true`. If not provided, a dynamic private IP will be assigned from the `lb_subnet_id` subnet."
  default     = null
}

variable "vault_subnet_id" {
  type        = string
  description = "Subnet ID for Vault server VMs."
}

#------------------------------------------------------------------------------
# DNS
#------------------------------------------------------------------------------
variable "create_vault_public_dns_record" {
  type        = bool
  description = "Boolean to create a DNS record for Vault in a public Azure DNS zone. `public_dns_zone_name` must also be provided when `true`."
  default     = false
}

variable "create_vault_private_dns_record" {
  type        = bool
  description = "Boolean to create a DNS record for Vault in a private Azure DNS zone. `private_dns_zone_name` must also be provided when `true`."
  default     = false
}

variable "public_dns_zone_name" {
  type        = string
  description = "Name of existing public Azure DNS zone to create DNS record in. Required when `create_vault_public_dns_record` is `true`."
  default     = null
}

variable "public_dns_zone_rg" {
  type        = string
  description = "Name of Resource Group where `public_dns_zone_name` resides. Required when `create_vault_public_dns_record` is `true`."
  default     = null
}

variable "private_dns_zone_name" {
  type        = string
  description = "Name of existing private Azure DNS zone to create DNS record in. Required when `create_vault_private_dns_record` is `true`."
  default     = null
}

variable "private_dns_zone_rg" {
  type        = string
  description = "Name of Resource Group where `private_dns_zone_name` resides. Required when `create_vault_private_dns_record` is `true`."
  default     = null
}

variable "create_private_dns_zone_vnet_link" {
  type        = bool
  description = "Boolean to create a virtual network link between the private DNS zone and the VNet. Only valid when `create_vault_private_dns_record` is `true`."
  default     = true
}

#------------------------------------------------------------------------------
# Virtual Machine Scaleset (VMSS)
#------------------------------------------------------------------------------
variable "vmss_vm_count" {
  type        = number
  description = "Number of VM instances in the VMSS."
  default     = 6
}

variable "vm_sku" {
  type        = string
  description = "SKU for VM size for the VMSS."
  default     = "Standard_D2s_v5"

  validation {
    condition     = can(regex("^[A-Za-z0-9_]+$", var.vm_sku))
    error_message = "Value can only contain alphanumeric characters and underscores."
  }
}

variable "vm_admin_username" {
  type        = string
  description = "Admin username for VMs in VMSS."
  default     = "ubuntu"
}

variable "vm_ssh_public_key" {
  type        = string
  description = "SSH public key for VMs in VMSS."
  default     = null
}

variable "vm_os_image" {
  description = "The OS image to use for the VM. Options are: redhat8, redhat9, ubuntu2204, ubuntu2404."
  type        = string
  default     = "ubuntu2404"

  validation {
    condition     = contains(["redhat8", "redhat9", "ubuntu2204", "ubuntu2404"], var.vm_os_image)
    error_message = "Value must be one of 'redhat8', 'redhat9', 'ubuntu2204', or 'ubuntu2404'."
  }
}

variable "vm_custom_image_name" {
  type        = string
  description = "Name of custom VM image to use for VMSS. If not using a custom image, leave this blank."
  default     = null
}

variable "vm_custom_image_rg_name" {
  type        = string
  description = "Name of Resource Group where `vm_custom_image_name` image resides. Only valid if `vm_custom_image_name` is not `null`."
  default     = null

  validation {
    condition     = var.vm_custom_image_name != null ? var.vm_custom_image_rg_name != null : true
    error_message = "A value is required when `vm_custom_image_name` is not `null`."
  }
}



variable "vm_disk_encryption_set_name" {
  type        = string
  description = "Name of the Disk Encryption Set to use for VMSS."
  default     = null
}

variable "vm_disk_encryption_set_rg" {
  type        = string
  description = "Name of the Resource Group where the Disk Encryption Set to use for VMSS exists."
  default     = null
}

variable "vm_enable_boot_diagnostics" {
  type        = bool
  description = "Boolean to enable boot diagnostics for VMSS."
  default     = false
}

variable "vm_boot_disk_size" {
  type        = number
  description = "The disk size (GB) to use to create the boot disk"
  default     = 64
}

variable "vm_vault_data_disk_size" {
  type        = number
  description = "The disk size (GB) to use to create the Vault data disk"
  default     = 200
}

variable "custom_startup_script_template" {
  type        = string
  description = "Name of custom startup script template file. File must exist within a directory named `./templates` within your current working directory."
  default     = null

  validation {
    condition     = var.custom_startup_script_template != null ? fileexists("${path.cwd}/templates/${var.custom_startup_script_template}") : true
    error_message = "File not found. Ensure the file exists within a directory named `./templates` within your current working directory."
  }
}

#------------------------------------------------------------------------------
# Key Vault
#------------------------------------------------------------------------------
variable "key_vault_cidr_allow_list" {
  type        = list(string)
  description = "List of CIDR blocks to allow access to the Key Vault."
  default     = []
}

variable "worker_msi_id" {
  type        = string
  description = "value of the worker MSI id"
  default     = null
}
