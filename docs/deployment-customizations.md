# Deployment Customizations

On this page are various deployment customizations and their corresponding input variables that you may set to meet your requirements.

## Load Balancer

This module defaults to creating a load balancer (`create_lb = true`) that is internal (`lb_is_internal = true`).

### Internal Load Balancer with Static (private) IP (default)

When using an internal load balancer you must set the static IP to an available IP address from our load balancer subnet.

```hcl
lb_private_ip = "<10.0.1.20>"
```

### External Load Balancer with Public IP

Here we must set the following boolean to false, and the module will automatically create and configure a Public IP for the load balancer frontend IP configuration.

```hcl
lb_is_internal = false
```

## DNS

If you have an existing Azure DNS zone (public or private) that you would like this module to create a DNS record within for the Vault API FQDN, the following input variables may be set. This is completely optional; you are free to create your own DNS record for the Vault FQDN resolving to the Vault load balancer out-of-band from this module.

### Azure Private DNS Zone

If your load balancer is internal (`lb_is_internal = true`) and a private, static IP is set (`lb_private_ip = "10.0.1.20"`), then the DNS record should be created in a private zone.

```hcl
create_vault_private_dns_record = true
private_dns_zone_name           = "<example.com>"
private_dns_zone_rg             = "<my-private-dns-zone-resource-group-name>"
```

### Azure Public DNS Zone

If your load balancer is external (`lb_is_internal = false`), the module will automatically create a public IP address for the load balancer, and hence the DNS record should be created in a public zone.

```hcl
create_vault_public_dns_record  = true
public_dns_zone_name            = "<example.com>"
public_dns_zone_rg              = "<my-public-dns-zone-resource-group-name>"
```

## Custom VM Image

If a custom VM image is preferred over using a standard marketplace image, the following variables may be set:

```hcl
vm_custom_image_name    = "<my-custom-ubuntu-2204-image>"
vm_custom_image_rg_name = "<my-custom-image-resource-group-name>"
```

## VM Disk Encryption Set

The following variables may be set to configure an existing Disk Encryption Set for the VMSS:

```hcl
vm_disk_encryption_set_name = <"my-disk-encryption-set-name">
vm_disk_encryption_set_rg   = <"my-disk-encryption-set-resource-group-name">
```

>📝 Note: ensure that your Key Vault that contains the key for the Disk Encryption Set has an Access Policy that allows the following key permissions: `Get`, `WrapKey`, and `UnwrapKey`.

## Custom startup script

While this is not recommended, this module supports the ability to use your own custom startup script to install. `var.custom_startup_script_template` # defaults to /templates/custom_data.sh.tpl

- The script must exist in a folder named ./templates within your current working directory that you are running Terraform from.
- The script must contain all of the variables (denoted by ${example-variable}) in the module-level startup script
- *Use at your own peril*
