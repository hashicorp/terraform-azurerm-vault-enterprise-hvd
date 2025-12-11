# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Resource Group Name
#------------------------------------------------------------------------------
output "resource_group_name" {
  value       = local.resource_group_name
  description = "Name of the Resource Group."
}

locals {
  vault_lb_ip = var.lb_is_internal ? azurerm_lb.vault[0].private_ip_address : azurerm_public_ip.vault_lb[0].ip_address
}

#------------------------------------------------------------------------------
# Vault
#------------------------------------------------------------------------------
output "load_balancer_ip" {
  value       = local.vault_lb_ip
  description = "IP address of load balancer's frontend configuration"
}

output "vault_server_private_ips" {
  description = "The Private IPs of the Vault servers that are spun up by VMSS"
  value       = data.azurerm_virtual_machine_scale_set.vault.instances.*.private_ip_address
}

output "vault_cli_config" {
  description = "Environment variables to configure the Vault CLI"
  value       = <<-EOF
    %{if var.create_lb == true~}
    export VAULT_ADDR=https://${local.vault_lb_ip}:8200
    %{else~}
    # No load balancer created; set VAULT_ADDR to the IPV4 address of any Vault instance
    export VAULT_ADDR=https://${data.azurerm_virtual_machine_scale_set.vault.instances[0].private_ip_address}:8200
    %{endif~}
    export VAULT_TLS_SERVER_NAME=${var.vault_fqdn}
    %{if var.vault_tls_ca_bundle_keyvault_secret_id != null~}
    export VAULT_CACERT=<path/to/ca-certificate>
    %{endif~}
  EOF
}