# Copyright IBM Corp. 2024, 2026
# SPDX-License-Identifier: MPL-2.0

output "vault_address" {
  description = "HTTPS address of the Vault cluster."
  value       = module.default_example.vault_address
}

output "vault_fqdn" {
  description = "FQDN of the Vault cluster (value for VAULT_TLS_SERVER_NAME)."
  value       = module.default_example.vault_fqdn
}

output "vault_cli_config" {
  value = <<-EOF
    Set the following environment variables to configure the Vault CLI:

    ${module.default_example.vault_cli_config}
  EOF
}