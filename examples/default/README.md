# Default Example

This example deploys Vault Enterprise aligned with HashiCorp Validated Design. This is the minimum configuration required to standup a highly-available Vault Enterprise cluster with:

* 3 redundancy zones each with one voter and one non-voter node
* Auto-unseal with the Azure Key Vault seal type
* Cloud auto-join for peer discovery
* Publicly-available load balanced Vault API endpoint
* End-to-end TLS

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ cp terraform.tfvars.example terraform.tfvars
# Update variable values
$ terraform plan
$ terraform apply
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.101 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_default_example"></a> [default\_example](#module\_default\_example) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Boolean to create a new Resource Group for this Vault deployment. | `bool` | `true` | no |
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | Friendly name prefix for uniquely naming Azure resources. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for this Vault deployment. | `string` | n/a | yes |
| <a name="input_prereqs_keyvault_name"></a> [prereqs\_keyvault\_name](#input\_prereqs\_keyvault\_name) | Name of the 'prereqs' Key Vault to use for prereqs Vault deployment. | `string` | n/a | yes |
| <a name="input_prereqs_keyvault_rg_name"></a> [prereqs\_keyvault\_rg\_name](#input\_prereqs\_keyvault\_rg\_name) | Name of the Resource Group where the 'prereqs' Key Vault resides. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of Resource Group to use for Vault cluster resources | `string` | `"example-vault"` | no |
| <a name="input_vault_fqdn"></a> [vault\_fqdn](#input\_vault\_fqdn) | Fully qualified domain name of the Vault cluster. This name __must__ match a SAN entry in the TLS server certificate. | `string` | n/a | yes |
| <a name="input_vault_license_keyvault_secret_id"></a> [vault\_license\_keyvault\_secret\_id](#input\_vault\_license\_keyvault\_secret\_id) | ID of Key Vault secret containing Vault license. | `string` | n/a | yes |
| <a name="input_vault_seal_azurekeyvault_unseal_key_name"></a> [vault\_seal\_azurekeyvault\_unseal\_key\_name](#input\_vault\_seal\_azurekeyvault\_unseal\_key\_name) | Name of the Azure Key Vault key to use for auto-unseal | `string` | n/a | yes |
| <a name="input_vault_seal_azurekeyvault_vault_name"></a> [vault\_seal\_azurekeyvault\_vault\_name](#input\_vault\_seal\_azurekeyvault\_vault\_name) | Name of the Azure Key Vault vault holding Vault's unseal key | `string` | n/a | yes |
| <a name="input_vault_subnet_id"></a> [vault\_subnet\_id](#input\_vault\_subnet\_id) | Subnet ID for Vault server VMs. | `string` | n/a | yes |
| <a name="input_vault_tls_ca_bundle_keyvault_secret_id"></a> [vault\_tls\_ca\_bundle\_keyvault\_secret\_id](#input\_vault\_tls\_ca\_bundle\_keyvault\_secret\_id) | ID of Key Vault secret containing Vault TLS custom CA bundle. | `string` | n/a | yes |
| <a name="input_vault_tls_cert_keyvault_secret_id"></a> [vault\_tls\_cert\_keyvault\_secret\_id](#input\_vault\_tls\_cert\_keyvault\_secret\_id) | ID of Key Vault secret containing Vault TLS certificate. | `string` | n/a | yes |
| <a name="input_vault_tls_privkey_keyvault_secret_id"></a> [vault\_tls\_privkey\_keyvault\_secret\_id](#input\_vault\_tls\_privkey\_keyvault\_secret\_id) | ID of Key Vault secret containing Vault TLS private key. | `string` | n/a | yes |
| <a name="input_vm_ssh_public_key_path"></a> [vm\_ssh\_public\_key\_path](#input\_vm\_ssh\_public\_key\_path) | File system path to the SSH public key for VMs in VMSS. | `string` | `null` | no |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | VNet ID where Vault resources will reside. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_ip"></a> [load\_balancer\_ip](#output\_load\_balancer\_ip) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the Resource Group. |
| <a name="output_vault_cli_config"></a> [vault\_cli\_config](#output\_vault\_cli\_config) | n/a |
| <a name="output_vault_server_private_ips"></a> [vault\_server\_private\_ips](#output\_vault\_server\_private\_ips) | n/a |
