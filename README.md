# Vault Enterprise HVD on Azure VM

Terraform module aligned with HashiCorp Validated Designs (HVD) to deploy Vault Enterprise on Microsoft Azure using Azure Virtual Machines. This module deploys Vault Enterprise with integrated storage.

![HVD Vault Architecture diagram](https://raw.githubusercontent.com/hashicorp/terraform-aws-vault-enterprise-hvd/main/docs/images/080-hvd-vault-networking-diagram.png "HVD Vault Architecture diagram")

## Prerequisites

This module requires the following to already be in place in Azure:

- [An Azure Subscription](#) with the following:
  - [Virtual Network](#)
  - [NAT gateway](#)
  - [Azure Key Vault](https://azure.microsoft.com/en-us/products/key-vault/)

## Deployment

Upon first deployment, Vault servers will auto-join and form a fresh cluster. The cluster will be in an uninitialized, sealed state. An operator must then connect to the cluster to initialize Vault. When auto-unseal is used via Azure Key Vault, the Vault nodes will automatically unseal upon initialization.

## Examples

Example deployment scenarios can be found in the `examples` directory of this repo [here](https://github.com/hashicorp/terraform-azurerm-vault-enterprise-hvd/tree/main/examples/README.md). These examples cover multiple capabilities of the module and are meant to serve as a starting point for operators.

## Deployment Options

This module by default deploys on Ubuntu 22.04. This can be changed by updating the following;

- `var.vm_image_publisher`
- `var.vm_image_offer`
- `var.vm_image_sku`
- `var.vm_image_version`

## Load Balancing

This module supports the deployment of Azure's TCP Layer 4 load balancer to sit in front of the Vault cluster. The load balancer can be external (public IP) or internal (private IP) and is configured to use Vault's `sys/health` API endpoint to determine health status of Vault to ensure clients are always directed to a healthy instance when possible.

The variable `lb_is_internal` is used to dictate if the load balancer should be exposed publicly. The default is `false`.

## Key Vault

This module requires auto-unseal and defaults to the Azure Key Vault seal mechanism. The module deploys both the Azure Key Vault and Key Vault Key to enable auto-unseal

<!-- BEGIN_TF_DOCS -->
## Module support

This open source software is maintained by the HashiCorp Technical Field Organization, independently of our enterprise products. While our Support Engineering team provides dedicated support for our enterprise offerings, this open source software is not included.

- For help using this open source software, please engage your account team.
- To report bugs/issues with this open source software, please open them directly against this code repository using the GitHub issues feature.

Please note that there is no official Service Level Agreement (SLA) for support of this software as a HashiCorp customer. This software falls under the definition of Community Software/Versions in your Agreement. We appreciate your understanding and collaboration in improving our open source projects.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.101 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.101 |

## Resources

| Name | Type |
|------|------|
| [azurerm_dns_a_record.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_key_vault_access_policy.prereqs_kv_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_lb.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.vault_servers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.vault_8200](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_linux_virtual_machine_scale_set.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_private_dns_a_record.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone_virtual_network_link.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_public_ip.vault_lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.prereqs_kv_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.resource_group_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vault_vmss_disk_encryption_set_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_disk_encryption_set.vmss](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/disk_encryption_set) | data source |
| [azurerm_dns_zone.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/dns_zone) | data source |
| [azurerm_image.custom](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/image) | data source |
| [azurerm_key_vault.prereqs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_private_dns_zone.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_virtual_machine_scale_set.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_machine_scale_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_package_names"></a> [additional\_package\_names](#input\_additional\_package\_names) | List of additional repository package names to install | `set(string)` | `[]` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of Azure Availability Zones to spread Vault resources across. | `set(string)` | <pre>[<br/>  "1",<br/>  "2",<br/>  "3"<br/>]</pre> | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of common tags for taggable Azure resources. | `map(string)` | `{}` | no |
| <a name="input_create_lb"></a> [create\_lb](#input\_create\_lb) | Boolean to create an Azure Load Balancer for Vault. | `bool` | `true` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Boolean to create a new Resource Group for this Vault deployment. | `bool` | `true` | no |
| <a name="input_create_vault_private_dns_record"></a> [create\_vault\_private\_dns\_record](#input\_create\_vault\_private\_dns\_record) | Boolean to create a DNS record for Vault in a private Azure DNS zone. `private_dns_zone_name` must also be provided when `true`. | `bool` | `false` | no |
| <a name="input_create_vault_public_dns_record"></a> [create\_vault\_public\_dns\_record](#input\_create\_vault\_public\_dns\_record) | Boolean to create a DNS record for Vault in a public Azure DNS zone. `public_dns_zone_name` must also be provided when `true`. | `bool` | `false` | no |
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | Friendly name prefix for uniquely naming Azure resources. | `string` | n/a | yes |
| <a name="input_is_govcloud_region"></a> [is\_govcloud\_region](#input\_is\_govcloud\_region) | Boolean indicating whether this Vault deployment is in an Azure Government Cloud region. | `bool` | `false` | no |
| <a name="input_key_vault_cidr_allow_list"></a> [key\_vault\_cidr\_allow\_list](#input\_key\_vault\_cidr\_allow\_list) | List of CIDR blocks to allow access to the Key Vault. | `list(string)` | `[]` | no |
| <a name="input_lb_is_internal"></a> [lb\_is\_internal](#input\_lb\_is\_internal) | Boolean to create an internal or external Azure Load Balancer for Vault. | `bool` | `false` | no |
| <a name="input_lb_private_ip"></a> [lb\_private\_ip](#input\_lb\_private\_ip) | Private IP address for internal Azure Load Balancer. Only valid when `lb_is_internal` is `true`. | `string` | `null` | no |
| <a name="input_lb_subnet_id"></a> [lb\_subnet\_id](#input\_lb\_subnet\_id) | Subnet ID for Azure load balancer. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for this Vault deployment. | `string` | n/a | yes |
| <a name="input_prereqs_keyvault_name"></a> [prereqs\_keyvault\_name](#input\_prereqs\_keyvault\_name) | Name of the 'prereqs' Key Vault to use for prereqs Vault deployment. | `string` | n/a | yes |
| <a name="input_prereqs_keyvault_rg_name"></a> [prereqs\_keyvault\_rg\_name](#input\_prereqs\_keyvault\_rg\_name) | Name of the Resource Group where the 'prereqs' Key Vault resides. | `string` | n/a | yes |
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
| <a name="input_vault_fqdn"></a> [vault\_fqdn](#input\_vault\_fqdn) | Fully qualified domain name of the Vault cluster. This name __must__ match a SAN entry in the TLS server certificate. | `string` | n/a | yes |
| <a name="input_vault_group_name"></a> [vault\_group\_name](#input\_vault\_group\_name) | Name of group to own Vault files and processes | `string` | `"vault"` | no |
| <a name="input_vault_license_keyvault_secret_id"></a> [vault\_license\_keyvault\_secret\_id](#input\_vault\_license\_keyvault\_secret\_id) | ID of Key Vault secret containing Vault license. | `string` | n/a | yes |
| <a name="input_vault_max_lease_ttl_duration"></a> [vault\_max\_lease\_ttl\_duration](#input\_vault\_max\_lease\_ttl\_duration) | The max lease TTL expressed as a time duration in hours, minutes and/or seconds (e.g. `4h30m10s`) | `string` | `"768h"` | no |
| <a name="input_vault_plugin_urls"></a> [vault\_plugin\_urls](#input\_vault\_plugin\_urls) | (optional list) List of Vault plugin fully qualified URLs (example ["https://releases.hashicorp.com/terraform-provider-oraclepaas/1.5.3/terraform-provider-oraclepaas_1.5.3_linux_amd64.zip"] for deployment to Vault plugins directory) | `list(string)` | `[]` | no |
| <a name="input_vault_port_api"></a> [vault\_port\_api](#input\_vault\_port\_api) | TCP port for Vault API listener | `number` | `8200` | no |
| <a name="input_vault_port_cluster"></a> [vault\_port\_cluster](#input\_vault\_port\_cluster) | TCP port for Vault cluster address | `number` | `8201` | no |
| <a name="input_vault_seal_azurekeyvault_unseal_key_name"></a> [vault\_seal\_azurekeyvault\_unseal\_key\_name](#input\_vault\_seal\_azurekeyvault\_unseal\_key\_name) | Name of the Azure Key Vault key to use for auto-unseal | `string` | n/a | yes |
| <a name="input_vault_seal_azurekeyvault_vault_name"></a> [vault\_seal\_azurekeyvault\_vault\_name](#input\_vault\_seal\_azurekeyvault\_vault\_name) | Name of the Azure Key Vault vault holding Vault's unseal key | `string` | n/a | yes |
| <a name="input_vault_seal_type"></a> [vault\_seal\_type](#input\_vault\_seal\_type) | n/a | `string` | `"azurekeyvault"` | no |
| <a name="input_vault_subnet_id"></a> [vault\_subnet\_id](#input\_vault\_subnet\_id) | Subnet ID for Vault server VMs. | `string` | n/a | yes |
| <a name="input_vault_tls_ca_bundle_keyvault_secret_id"></a> [vault\_tls\_ca\_bundle\_keyvault\_secret\_id](#input\_vault\_tls\_ca\_bundle\_keyvault\_secret\_id) | ID of Key Vault secret containing Vault TLS custom CA bundle. | `string` | n/a | yes |
| <a name="input_vault_tls_cert_keyvault_secret_id"></a> [vault\_tls\_cert\_keyvault\_secret\_id](#input\_vault\_tls\_cert\_keyvault\_secret\_id) | ID of Key Vault secret containing Vault TLS certificate. | `string` | n/a | yes |
| <a name="input_vault_tls_disable_client_certs"></a> [vault\_tls\_disable\_client\_certs](#input\_vault\_tls\_disable\_client\_certs) | Disable Vault UI prompt for client certificates | `bool` | `false` | no |
| <a name="input_vault_tls_privkey_keyvault_secret_id"></a> [vault\_tls\_privkey\_keyvault\_secret\_id](#input\_vault\_tls\_privkey\_keyvault\_secret\_id) | ID of Key Vault secret containing Vault TLS private key. | `string` | n/a | yes |
| <a name="input_vault_tls_require_and_verify_client_cert"></a> [vault\_tls\_require\_and\_verify\_client\_cert](#input\_vault\_tls\_require\_and\_verify\_client\_cert) | Require and verify client certs on API requests | `bool` | `false` | no |
| <a name="input_vault_user_name"></a> [vault\_user\_name](#input\_vault\_user\_name) | Name of system user to own Vault files and processes | `string` | `"vault"` | no |
| <a name="input_vault_version"></a> [vault\_version](#input\_vault\_version) | Version of Vault to install. | `string` | `"1.17.3+ent"` | no |
| <a name="input_vm_admin_username"></a> [vm\_admin\_username](#input\_vm\_admin\_username) | Admin username for VMs in VMSS. | `string` | `"ubuntu"` | no |
| <a name="input_vm_boot_disk_size"></a> [vm\_boot\_disk\_size](#input\_vm\_boot\_disk\_size) | The disk size (GB) to use to create the boot disk | `number` | `64` | no |
| <a name="input_vm_custom_image_name"></a> [vm\_custom\_image\_name](#input\_vm\_custom\_image\_name) | Name of custom VM image to use for VMSS. If not using a custom image, leave this set to null. | `string` | `null` | no |
| <a name="input_vm_custom_image_rg_name"></a> [vm\_custom\_image\_rg\_name](#input\_vm\_custom\_image\_rg\_name) | Resource Group name where the custom VM image resides. Only valid if `vm_custom_image_name` is not null. | `string` | `null` | no |
| <a name="input_vm_disk_encryption_set_name"></a> [vm\_disk\_encryption\_set\_name](#input\_vm\_disk\_encryption\_set\_name) | Name of the Disk Encryption Set to use for VMSS. | `string` | `null` | no |
| <a name="input_vm_disk_encryption_set_rg"></a> [vm\_disk\_encryption\_set\_rg](#input\_vm\_disk\_encryption\_set\_rg) | Name of the Resource Group where the Disk Encryption Set to use for VMSS exists. | `string` | `null` | no |
| <a name="input_vm_enable_boot_diagnostics"></a> [vm\_enable\_boot\_diagnostics](#input\_vm\_enable\_boot\_diagnostics) | Boolean to enable boot diagnostics for VMSS. | `bool` | `false` | no |
| <a name="input_vm_image_offer"></a> [vm\_image\_offer](#input\_vm\_image\_offer) | Offer of the VM image. | `string` | `"0001-com-ubuntu-server-jammy"` | no |
| <a name="input_vm_image_publisher"></a> [vm\_image\_publisher](#input\_vm\_image\_publisher) | Publisher of the VM image. | `string` | `"Canonical"` | no |
| <a name="input_vm_image_sku"></a> [vm\_image\_sku](#input\_vm\_image\_sku) | SKU of the VM image. | `string` | `"22_04-lts-gen2"` | no |
| <a name="input_vm_image_version"></a> [vm\_image\_version](#input\_vm\_image\_version) | Version of the VM image. | `string` | `"latest"` | no |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | SKU for VM size for the VMSS. | `string` | `"Standard_D2s_v5"` | no |
| <a name="input_vm_ssh_public_key"></a> [vm\_ssh\_public\_key](#input\_vm\_ssh\_public\_key) | SSH public key for VMs in VMSS. | `string` | `null` | no |
| <a name="input_vm_vault_data_disk_size"></a> [vm\_vault\_data\_disk\_size](#input\_vm\_vault\_data\_disk\_size) | The disk size (GB) to use to create the Vault data disk | `number` | `200` | no |
| <a name="input_vmss_vm_count"></a> [vmss\_vm\_count](#input\_vmss\_vm\_count) | Number of VM instances in the VMSS. | `number` | `6` | no |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | VNet ID where Vault resources will reside. | `string` | n/a | yes |
| <a name="input_worker_msi_id"></a> [worker\_msi\_id](#input\_worker\_msi\_id) | value of the worker MSI id | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_ip"></a> [load\_balancer\_ip](#output\_load\_balancer\_ip) | IP address of load balancer's frontend configuration |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the Resource Group. |
| <a name="output_vault_cli_config"></a> [vault\_cli\_config](#output\_vault\_cli\_config) | Environment variables to configure the Vault CLI |
| <a name="output_vault_server_private_ips"></a> [vault\_server\_private\_ips](#output\_vault\_server\_private\_ips) | The Private IPs of the Vault servers that are spun up by VMSS |
<!-- END_TF_DOCS -->
