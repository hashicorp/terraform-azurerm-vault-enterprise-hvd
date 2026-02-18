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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.101 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_default_example"></a> [default\_example](#module\_default\_example) | ../.. | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | Friendly name prefix for uniquely naming Azure resources. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for this Vault deployment. | `string` | n/a | yes |
| <a name="input_prereqs_keyvault_name"></a> [prereqs\_keyvault\_name](#input\_prereqs\_keyvault\_name) | Name of the 'prereqs' Key Vault to use for prereqs Vault deployment. | `string` | n/a | yes |
| <a name="input_prereqs_keyvault_rg_name"></a> [prereqs\_keyvault\_rg\_name](#input\_prereqs\_keyvault\_rg\_name) | Name of the Resource Group where the 'prereqs' Key Vault resides. | `string` | n/a | yes |
| <a name="input_vault_fqdn"></a> [vault\_fqdn](#input\_vault\_fqdn) | Fully qualified domain name of the Vault cluster. This name __must__ match a SAN entry in the TLS server certificate. | `string` | n/a | yes |
| <a name="input_vault_license_keyvault_secret_id"></a> [vault\_license\_keyvault\_secret\_id](#input\_vault\_license\_keyvault\_secret\_id) | ID of Key Vault secret containing Vault license. | `string` | n/a | yes |
| <a name="input_vault_seal_azurekeyvault_unseal_key_name"></a> [vault\_seal\_azurekeyvault\_unseal\_key\_name](#input\_vault\_seal\_azurekeyvault\_unseal\_key\_name) | Name of the Azure Key Vault key to use for auto-unseal | `string` | n/a | yes |
| <a name="input_vault_seal_azurekeyvault_vault_name"></a> [vault\_seal\_azurekeyvault\_vault\_name](#input\_vault\_seal\_azurekeyvault\_vault\_name) | Name of the Azure Key Vault vault holding Vault's unseal key | `string` | n/a | yes |
| <a name="input_vault_subnet_id"></a> [vault\_subnet\_id](#input\_vault\_subnet\_id) | Subnet ID for Vault server VMs. | `string` | n/a | yes |
| <a name="input_vault_tls_ca_bundle_keyvault_secret_id"></a> [vault\_tls\_ca\_bundle\_keyvault\_secret\_id](#input\_vault\_tls\_ca\_bundle\_keyvault\_secret\_id) | ID of Key Vault secret containing Vault TLS custom CA bundle. | `string` | n/a | yes |
| <a name="input_vault_tls_cert_keyvault_secret_id"></a> [vault\_tls\_cert\_keyvault\_secret\_id](#input\_vault\_tls\_cert\_keyvault\_secret\_id) | ID of Key Vault secret containing Vault TLS certificate. | `string` | n/a | yes |
| <a name="input_vault_tls_privkey_keyvault_secret_id"></a> [vault\_tls\_privkey\_keyvault\_secret\_id](#input\_vault\_tls\_privkey\_keyvault\_secret\_id) | ID of Key Vault secret containing Vault TLS private key. | `string` | n/a | yes |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | VNet ID where Vault resources will reside. | `string` | n/a | yes |
| <a name="input_additional_package_names"></a> [additional\_package\_names](#input\_additional\_package\_names) | List of additional repository package names to install | `set(string)` | `[]` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of Azure Availability Zones to spread Vault resources across. | `set(string)` | <pre>[<br/>  "1",<br/>  "2",<br/>  "3"<br/>]</pre> | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of common tags for taggable Azure resources. | `map(string)` | `{}` | no |
| <a name="input_create_lb"></a> [create\_lb](#input\_create\_lb) | Boolean to create an Azure Load Balancer for Vault. | `bool` | `true` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Boolean to create a new Resource Group for this Vault deployment. | `bool` | `true` | no |
| <a name="input_create_vault_private_dns_record"></a> [create\_vault\_private\_dns\_record](#input\_create\_vault\_private\_dns\_record) | Boolean to create a DNS record for Vault in a private Azure DNS zone. `private_dns_zone_name` must also be provided when `true`. | `bool` | `false` | no |
| <a name="input_create_vault_public_dns_record"></a> [create\_vault\_public\_dns\_record](#input\_create\_vault\_public\_dns\_record) | Boolean to create a DNS record for Vault in a public Azure DNS zone. `public_dns_zone_name` must also be provided when `true`. | `bool` | `false` | no |
| <a name="input_custom_startup_script_template"></a> [custom\_startup\_script\_template](#input\_custom\_startup\_script\_template) | Name of custom startup script template file. File must exist within a directory named `./templates` within your current working directory. | `string` | `null` | no |
| <a name="input_is_govcloud_region"></a> [is\_govcloud\_region](#input\_is\_govcloud\_region) | Boolean indicating whether this Vault deployment is in an Azure Government Cloud region. | `bool` | `false` | no |
| <a name="input_key_vault_cidr_allow_list"></a> [key\_vault\_cidr\_allow\_list](#input\_key\_vault\_cidr\_allow\_list) | List of CIDR blocks to allow access to the Key Vault. | `list(string)` | `[]` | no |
| <a name="input_lb_is_internal"></a> [lb\_is\_internal](#input\_lb\_is\_internal) | Boolean to create an internal or external Azure Load Balancer for Vault. | `bool` | `false` | no |
| <a name="input_lb_private_ip"></a> [lb\_private\_ip](#input\_lb\_private\_ip) | Private IP address for internal Azure Load Balancer. Only valid when `lb_is_internal` is `true`. | `string` | `null` | no |
| <a name="input_lb_subnet_id"></a> [lb\_subnet\_id](#input\_lb\_subnet\_id) | Subnet ID for Azure load balancer. | `string` | `null` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Name of existing private Azure DNS zone to create DNS record in. Required when `create_vault_private_dns_record` is `true`. | `string` | `null` | no |
| <a name="input_private_dns_zone_rg"></a> [private\_dns\_zone\_rg](#input\_private\_dns\_zone\_rg) | Name of Resource Group where `private_dns_zone_name` resides. Required when `create_vault_private_dns_record` is `true`. | `string` | `null` | no |
| <a name="input_public_dns_zone_name"></a> [public\_dns\_zone\_name](#input\_public\_dns\_zone\_name) | Name of existing public Azure DNS zone to create DNS record in. Required when `create_vault_public_dns_record` is `true`. | `string` | `null` | no |
| <a name="input_public_dns_zone_rg"></a> [public\_dns\_zone\_rg](#input\_public\_dns\_zone\_rg) | Name of Resource Group where `public_dns_zone_name` resides. Required when `create_vault_public_dns_record` is `true`. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of Resource Group to use for Vault cluster resources | `string` | `"vault-ent-rg"` | no |
| <a name="input_systemd_dir"></a> [systemd\_dir](#input\_systemd\_dir) | Path to systemd directory for unit files | `string` | `"/lib/systemd/system"` | no |
| <a name="input_vault_default_lease_ttl_duration"></a> [vault\_default\_lease\_ttl\_duration](#input\_vault\_default\_lease\_ttl\_duration) | The default lease TTL expressed as a time duration in hours, minutes and/or seconds (e.g. `4h30m10s`) | `string` | `"1h"` | no |
| <a name="input_vault_dir_bin"></a> [vault\_dir\_bin](#input\_vault\_dir\_bin) | Path to install Vault Enterprise binary | `string` | `"/usr/bin"` | no |
| <a name="input_vault_dir_config"></a> [vault\_dir\_config](#input\_vault\_dir\_config) | Path to install Vault Enterprise binary | `string` | `"/etc/vault.d"` | no |
| <a name="input_vault_dir_home"></a> [vault\_dir\_home](#input\_vault\_dir\_home) | Path to hold data, plugins and license directories | `string` | `"/opt/vault"` | no |
| <a name="input_vault_dir_logs"></a> [vault\_dir\_logs](#input\_vault\_dir\_logs) | Path to hold Vault file audit device logs | `string` | `"/var/log/vault"` | no |
| <a name="input_vault_disable_mlock"></a> [vault\_disable\_mlock](#input\_vault\_disable\_mlock) | Boolean to disable mlock. Mlock should be disabled when using Raft integrated storage. | `bool` | `true` | no |
| <a name="input_vault_enable_ui"></a> [vault\_enable\_ui](#input\_vault\_enable\_ui) | Boolean to enable Vault's web UI | `bool` | `true` | no |
| <a name="input_vault_group_name"></a> [vault\_group\_name](#input\_vault\_group\_name) | Name of group to own Vault files and processes | `string` | `"vault"` | no |
| <a name="input_vault_max_lease_ttl_duration"></a> [vault\_max\_lease\_ttl\_duration](#input\_vault\_max\_lease\_ttl\_duration) | The max lease TTL expressed as a time duration in hours, minutes and/or seconds (e.g. `4h30m10s`) | `string` | `"768h"` | no |
| <a name="input_vault_plugin_urls"></a> [vault\_plugin\_urls](#input\_vault\_plugin\_urls) | (optional list) List of Vault plugin fully qualified URLs (example ["https://releases.hashicorp.com/terraform-provider-oraclepaas/1.5.3/terraform-provider-oraclepaas_1.5.3_linux_amd64.zip"] for deployment to Vault plugins directory) | `list(string)` | `[]` | no |
| <a name="input_vault_port_api"></a> [vault\_port\_api](#input\_vault\_port\_api) | TCP port for Vault API listener | `number` | `8200` | no |
| <a name="input_vault_port_cluster"></a> [vault\_port\_cluster](#input\_vault\_port\_cluster) | TCP port for Vault cluster address | `number` | `8201` | no |
| <a name="input_vault_raft_performance_multiplier"></a> [vault\_raft\_performance\_multiplier](#input\_vault\_raft\_performance\_multiplier) | Raft performance multiplier value. Defaults to 5, which is the default Vault value. | `number` | `5` | no |
| <a name="input_vault_seal_type"></a> [vault\_seal\_type](#input\_vault\_seal\_type) | n/a | `string` | `"azurekeyvault"` | no |
| <a name="input_vault_telemetry_config"></a> [vault\_telemetry\_config](#input\_vault\_telemetry\_config) | Enable telemetry for Vault | `map(string)` | `null` | no |
| <a name="input_vault_tls_disable_client_certs"></a> [vault\_tls\_disable\_client\_certs](#input\_vault\_tls\_disable\_client\_certs) | Disable Vault UI prompt for client certificates | `bool` | `false` | no |
| <a name="input_vault_tls_require_and_verify_client_cert"></a> [vault\_tls\_require\_and\_verify\_client\_cert](#input\_vault\_tls\_require\_and\_verify\_client\_cert) | Require and verify client certs on API requests | `bool` | `false` | no |
| <a name="input_vault_user_name"></a> [vault\_user\_name](#input\_vault\_user\_name) | Name of system user to own Vault files and processes | `string` | `"vault"` | no |
| <a name="input_vault_version"></a> [vault\_version](#input\_vault\_version) | Version of Vault to install. | `string` | `"1.17.3+ent"` | no |
| <a name="input_vm_admin_username"></a> [vm\_admin\_username](#input\_vm\_admin\_username) | Admin username for VMs in VMSS. | `string` | `"ubuntu"` | no |
| <a name="input_vm_boot_disk_size"></a> [vm\_boot\_disk\_size](#input\_vm\_boot\_disk\_size) | The disk size (GB) to use to create the boot disk | `number` | `64` | no |
| <a name="input_vm_custom_image_name"></a> [vm\_custom\_image\_name](#input\_vm\_custom\_image\_name) | Name of custom VM image to use for VMSS. If not using a custom image, leave this blank. | `string` | `null` | no |
| <a name="input_vm_custom_image_rg_name"></a> [vm\_custom\_image\_rg\_name](#input\_vm\_custom\_image\_rg\_name) | Name of Resource Group where `vm_custom_image_name` image resides. Only valid if `vm_custom_image_name` is not `null`. | `string` | `null` | no |
| <a name="input_vm_disk_encryption_set_name"></a> [vm\_disk\_encryption\_set\_name](#input\_vm\_disk\_encryption\_set\_name) | Name of the Disk Encryption Set to use for VMSS. | `string` | `null` | no |
| <a name="input_vm_disk_encryption_set_rg"></a> [vm\_disk\_encryption\_set\_rg](#input\_vm\_disk\_encryption\_set\_rg) | Name of the Resource Group where the Disk Encryption Set to use for VMSS exists. | `string` | `null` | no |
| <a name="input_vm_enable_boot_diagnostics"></a> [vm\_enable\_boot\_diagnostics](#input\_vm\_enable\_boot\_diagnostics) | Boolean to enable boot diagnostics for VMSS. | `bool` | `false` | no |
| <a name="input_vm_os_image"></a> [vm\_os\_image](#input\_vm\_os\_image) | The OS image to use for the VM. Options are: redhat8, redhat9, ubuntu2204, ubuntu2404. | `string` | `"ubuntu2404"` | no |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | SKU for VM size for the VMSS. | `string` | `"Standard_D2s_v5"` | no |
| <a name="input_vm_ssh_public_key"></a> [vm\_ssh\_public\_key](#input\_vm\_ssh\_public\_key) | SSH public key for VMs in VMSS. | `string` | `null` | no |
| <a name="input_vm_vault_data_disk_size"></a> [vm\_vault\_data\_disk\_size](#input\_vm\_vault\_data\_disk\_size) | The disk size (GB) to use to create the Vault data disk | `number` | `200` | no |
| <a name="input_vmss_vm_count"></a> [vmss\_vm\_count](#input\_vmss\_vm\_count) | Number of VM instances in the VMSS. | `number` | `6` | no |
| <a name="input_worker_msi_id"></a> [worker\_msi\_id](#input\_worker\_msi\_id) | value of the worker MSI id | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vault_cli_config"></a> [vault\_cli\_config](#output\_vault\_cli\_config) | n/a |
<!-- END_TF_DOCS -->