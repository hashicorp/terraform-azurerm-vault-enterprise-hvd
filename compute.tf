# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Custom Data (cloud-init) arguments
#------------------------------------------------------------------------------
locals {
  custom_startup_script_template = var.custom_startup_script_template != null ? "${path.cwd}/templates/${var.custom_startup_script_template}" : "${path.module}/templates/custom_data.sh.tpl"

  custom_data_args = {
    # used to set azure-cli context to AzureUSGovernment
    is_govcloud_region = var.is_govcloud_region

    # system paths and settings
    systemd_dir              = var.systemd_dir,
    vault_dir_bin            = var.vault_dir_bin,
    vault_dir_config         = var.vault_dir_config,
    vault_dir_home           = var.vault_dir_home,
    vault_dir_logs           = var.vault_dir_logs,
    vault_user_name          = var.vault_user_name,
    vault_group_name         = var.vault_group_name,
    additional_package_names = join(" ", var.additional_package_names)

    # installation secrets
    vault_license_keyvault_secret_id       = var.vault_license_keyvault_secret_id
    vault_tls_cert_keyvault_secret_id      = var.vault_tls_cert_keyvault_secret_id
    vault_tls_privkey_keyvault_secret_id   = var.vault_tls_privkey_keyvault_secret_id
    vault_tls_ca_bundle_keyvault_secret_id = var.vault_tls_ca_bundle_keyvault_secret_id == null ? "NONE" : var.vault_tls_ca_bundle_keyvault_secret_id,

    # Vault settings
    vault_version                            = var.vault_version,
    vault_disable_mlock                      = var.vault_disable_mlock,
    vault_enable_ui                          = var.vault_enable_ui,
    vault_default_lease_ttl_duration         = var.vault_default_lease_ttl_duration,
    vault_max_lease_ttl_duration             = var.vault_max_lease_ttl_duration,
    vault_port_api                           = var.vault_port_api,
    vault_port_cluster                       = var.vault_port_cluster,
    vault_telemetry_config                   = var.vault_telemetry_config == null ? {} : var.vault_telemetry_config,
    vault_tls_require_and_verify_client_cert = var.vault_tls_require_and_verify_client_cert,
    vault_tls_disable_client_certs           = var.vault_tls_disable_client_certs,
    vault_leader_tls_servername              = var.vault_fqdn,
    vault_seal_type                          = var.vault_seal_type,
    vault_seal_azurekeyvault_vault_name      = var.vault_seal_azurekeyvault_vault_name,
    vault_seal_azurekeyvault_unseal_key_name = var.vault_seal_azurekeyvault_unseal_key_name,
    vault_plugin_urls                        = var.vault_plugin_urls,
    vault_raft_performance_multiplier        = var.vault_raft_performance_multiplier
    # Used for tagging VMs for auto-join
    friendly_name_prefix = var.friendly_name_prefix
    vm_domain_suffix     = var.vm_domain_suffix != null ? var.vm_domain_suffix : "NONE"
  }
}

# #------------------------------------------------------------------------------
# # Virtual Machine Scale Set (VMSS)
# #------------------------------------------------------------------------------
# resource "azurerm_linux_virtual_machine_scale_set" "vault" {
#   name                = "${var.friendly_name_prefix}-vault-vmss"
#   resource_group_name = local.resource_group_name
#   location            = var.location
#   instances           = var.vmss_vm_count
#   sku                 = var.vm_sku
#   admin_username      = var.vm_admin_username
#   overprovision       = false
#   upgrade_mode        = "Manual"
#   zone_balance        = true
#   zones               = var.availability_zones
#   # health_probe_id     = var.create_lb == true ? azurerm_lb_probe.vault[0].id : null

#   custom_data = base64encode(templatefile("${local.custom_startup_script_template}", local.custom_data_args))

#   scale_in {
#     rule = "OldestVM"
#   }

#   identity {
#     type         = "UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.vault.id]
#   }

#   dynamic "admin_ssh_key" {
#     for_each = var.vm_ssh_public_key != null ? [1] : []

#     content {
#       username   = var.vm_admin_username
#       public_key = var.vm_ssh_public_key
#     }
#   }

#   source_image_id = var.vm_custom_image_name != null ? data.azurerm_image.custom[0].id : null

#   dynamic "source_image_reference" {
#     for_each = var.vm_custom_image_name == null ? [true] : []

#     content {
#       publisher = local.vm_image_publisher
#       offer     = local.vm_image_offer
#       sku       = local.vm_image_sku
#       version   = data.azurerm_platform_image.latest_os_image.version
#     }
#   }

#   network_interface {
#     name    = "vault-vm-nic"
#     primary = true

#     ip_configuration {
#       name      = "internal"
#       primary   = true
#       subnet_id = var.vault_subnet_id
#       load_balancer_backend_address_pool_ids = [
#         azurerm_lb_backend_address_pool.vault_servers[0].id,
#         # azurerm_lb_backend_address_pool.vault_servers_443[0].id,
#       ]
#     }
#   }

#   os_disk {
#     caching                = "ReadWrite"
#     storage_account_type   = "Premium_LRS"
#     disk_size_gb           = var.vm_boot_disk_size
#     disk_encryption_set_id = var.vm_disk_encryption_set_name != null && var.vm_disk_encryption_set_rg != null ? data.azurerm_disk_encryption_set.vmss[0].id : null
#   }

#   data_disk {
#     lun                  = 0
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#     disk_size_gb         = var.vm_vault_data_disk_size
#   }

#   # automatic_instance_repair {
#   #   enabled      = true
#   #   grace_period = "PT15M"
#   # }

#   dynamic "boot_diagnostics" {
#     for_each = var.vm_enable_boot_diagnostics == true ? [1] : []
#     content {}
#   }

#   tags = merge(
#     { "Name" = "${var.friendly_name_prefix}-vault-vmss" },
#     var.common_tags
#   )
# }

# data "azurerm_virtual_machine_scale_set" "vault" {
#   name                = azurerm_linux_virtual_machine_scale_set.vault.name
#   resource_group_name = local.resource_group_name
# }

#------------------------------------------------------------------------------
# Debug rendered Vault custom_data script from template
#------------------------------------------------------------------------------
# resource "local_file" "debug_custom_data" {
#   content  = templatefile("${path.module}/templates/custom_data.sh.tpl", local.custom_data_args)
#   filename = "${path.module}/debug/debug_custom_data.sh"
# }


## MANUAL VMs (experimental)
resource "azurerm_network_interface" "vault_nic" {
  count               = var.vmss_vm_count
  resource_group_name = local.resource_group_name
  location            = var.location
  name                = "vault-vm-nic-${count.index}"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vault_subnet_id
    private_ip_address_allocation = "Dynamic"
    # TODO: this vv
    # load_balancer_backend_address_pool_ids = [
    #   azurerm_lb_backend_address_pool.vault_servers[0].id,
    # ]
  }
}

resource "azurerm_lb_backend_address_pool_address" "vault_pool_address" {
  count                   = var.create_lb == true ? var.vmss_vm_count : 0
  name                    = "vault-lb-backend-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.vault_servers[0].id
  virtual_network_id      = var.vnet_id
  ip_address              = azurerm_network_interface.vault_nic[count.index].private_ip_address
}


resource "azurerm_linux_virtual_machine" "vault_vm" {
  count               = var.vmss_vm_count
  name                = "${var.friendly_name_prefix}-vault-${count.index}"
  resource_group_name = local.resource_group_name
  location            = var.location

  size           = var.vm_sku
  admin_username = var.vm_admin_username

  zone = element(tolist(var.availability_zones), count.index)
  # health_probe_id     = var.create_lb == true ? azurerm_lb_probe.vault[0].id : null

  custom_data = base64encode(templatefile("${local.custom_startup_script_template}", local.custom_data_args))

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.vault.id]
  }

  dynamic "admin_ssh_key" {
    for_each = var.vm_ssh_public_key != null ? [1] : []

    content {
      username   = var.vm_admin_username
      public_key = var.vm_ssh_public_key
    }
  }

  source_image_id = var.vm_custom_image_name != null ? data.azurerm_image.custom[0].id : null

  dynamic "source_image_reference" {
    for_each = var.vm_custom_image_name == null ? [true] : []

    content {
      publisher = local.vm_image_publisher
      offer     = local.vm_image_offer
      sku       = local.vm_image_sku
      version   = data.azurerm_platform_image.latest_os_image.version
    }
  }

  network_interface_ids = [
    azurerm_network_interface.vault_nic[count.index].id,
  ]

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_size_gb           = var.vm_boot_disk_size
    disk_encryption_set_id = var.vm_disk_encryption_set_name != null && var.vm_disk_encryption_set_rg != null ? data.azurerm_disk_encryption_set.vmss[0].id : null
  }

  dynamic "boot_diagnostics" {
    for_each = var.vm_enable_boot_diagnostics == true ? [1] : []
    content {}
  }

  tags = merge(
    { "Name" = "${var.friendly_name_prefix}-vault-${count.index}" },
    { "VaultCluster" = var.friendly_name_prefix },
    var.common_tags
  )
}

resource "azurerm_managed_disk" "vault_data" {
  count                = var.vmss_vm_count
  name                 = "${var.friendly_name_prefix}-vault-data-disk-${count.index}"
  location             = var.location
  resource_group_name  = local.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.vm_vault_data_disk_size
  zone                 = element(tolist(var.availability_zones), count.index)
}

resource "azurerm_virtual_machine_data_disk_attachment" "vault_data_attachment" {
  count              = var.vmss_vm_count
  managed_disk_id    = azurerm_managed_disk.vault_data[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vault_vm[count.index].id
  lun                = "0"
  caching            = "ReadWrite"
}
