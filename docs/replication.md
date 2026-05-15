# Replication

This guide covers the Azure networking and module configuration required to use Vault Enterprise disaster recovery (DR) or performance replication with this module.

Each invocation of `terraform-azurerm-vault-enterprise-hvd` deploys exactly one Vault cluster. To build a replicated topology, deploy the module twice and connect the two environments with Azure networking, DNS, and TLS configuration that allow the clusters to reach each other.

## Replication model

Use one module invocation per cluster:

- a **primary** cluster
- a **secondary** cluster

Each cluster should have its own:

- resource group
- virtual network and subnets
- load balancer frontend IP
- Vault FQDN
- `friendly_name_prefix`

## Required Azure configuration

Replication depends on both the load balancer address for cluster traffic and cross-VNet hostname resolution for the individual Vault nodes.

Before enabling replication, make sure the following are in place:

1. **Bidirectional VNet peering** between the primary and secondary VNets.
2. **Private DNS resolution** for both cluster FQDNs and the per-node VM hostnames.
3. **Network security rules** that allow the peer cluster to reach:
   - TCP `8200` for the Vault API
   - TCP `8201` for Vault cluster and replication traffic
4. **TLS certificates** that cover:
   - each cluster's `vault_fqdn`
   - the VM hostnames generated from `vm_domain_suffix`

## Module settings required for replication

The following inputs are the key replication-related settings:

```hcl
lb_is_internal                       = true
create_lb                            = true
enable_vault_cluster_port_listener   = true
create_vault_private_dns_record      = true
private_dns_zone_name                = azurerm_private_dns_zone.vault.name
private_dns_zone_rg                  = azurerm_resource_group.network.name
create_private_dns_zone_vnet_link    = false
vm_domain_suffix                     = azurerm_private_dns_zone.vault.name
```

### Why these settings matter

- `enable_vault_cluster_port_listener = true` adds the Azure Load Balancer rule and probe for port `8201`.
- `create_vault_private_dns_record = true` creates the cluster DNS record for the load balancer frontend.
- `vm_domain_suffix` ensures Vault nodes use a resolvable hostname suffix across both VNets. This is required because node-level addresses still appear in replication metadata and internal cluster communication.
- `create_private_dns_zone_vnet_link = false` is recommended when the root module manages links for more than one VNet into the same private DNS zone.

## Example Azure networking

The following sanitized example shows one way to prepare shared DNS, bidirectional VNet peering, and the minimum NSG rules for replication. Adjust naming, addressing, and resource placement for your environment.

For brevity, this example assumes the virtual networks and load balancer NSGs already exist as `azurerm_virtual_network.primary`, `azurerm_virtual_network.secondary`, `azurerm_network_security_group.primary_lb`, and `azurerm_network_security_group.secondary_lb`.

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "network" {
  name     = "rg-vault-network"
  location = "centralus"
}

resource "azurerm_private_dns_zone" "vault" {
  name                = "vault.internal.example.com"
  resource_group_name = azurerm_resource_group.network.name
}

resource "azurerm_virtual_network_peering" "primary_to_secondary" {
  name                      = "primary-to-secondary"
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = azurerm_virtual_network.primary.name
  remote_virtual_network_id = azurerm_virtual_network.secondary.id
}

resource "azurerm_virtual_network_peering" "secondary_to_primary" {
  name                      = "secondary-to-primary"
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = azurerm_virtual_network.secondary.name
  remote_virtual_network_id = azurerm_virtual_network.primary.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "primary" {
  name                  = "vault-primary-link"
  resource_group_name   = azurerm_resource_group.network.name
  private_dns_zone_name = azurerm_private_dns_zone.vault.name
  virtual_network_id    = azurerm_virtual_network.primary.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "secondary" {
  name                  = "vault-secondary-link"
  resource_group_name   = azurerm_resource_group.network.name
  private_dns_zone_name = azurerm_private_dns_zone.vault.name
  virtual_network_id    = azurerm_virtual_network.secondary.id
}

resource "azurerm_network_security_rule" "primary_api_from_secondary" {
  name                        = "allow-secondary-to-primary-api"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8200"
  source_address_prefix       = azurerm_virtual_network.secondary.address_space[0]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.primary_lb.name
}

resource "azurerm_network_security_rule" "primary_cluster_from_secondary" {
  name                        = "allow-secondary-to-primary-cluster"
  priority                    = 111
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8201"
  source_address_prefix       = azurerm_virtual_network.secondary.address_space[0]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.primary_lb.name
}

resource "azurerm_network_security_rule" "secondary_api_from_primary" {
  name                        = "allow-primary-to-secondary-api"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8200"
  source_address_prefix       = azurerm_virtual_network.primary.address_space[0]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.secondary_lb.name
}

resource "azurerm_network_security_rule" "secondary_cluster_from_primary" {
  name                        = "allow-primary-to-secondary-cluster"
  priority                    = 111
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8201"
  source_address_prefix       = azurerm_virtual_network.primary.address_space[0]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.secondary_lb.name
}
```

## Example module configuration

This example assumes the following already exist:

- a Key Vault containing the Vault license, TLS certificate, private key, and CA bundle
- a Key Vault key for auto-unseal
- one resource group per cluster
- one VNet, Vault subnet, and load balancer subnet per cluster

```hcl
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "vault" {
  name                = "kv-vault-shared"
  resource_group_name = "rg-vault-shared"
}

data "azurerm_key_vault_secret" "vault_license" {
  name         = "vault-license"
  key_vault_id = data.azurerm_key_vault.vault.id
}

data "azurerm_key_vault_secret" "vault_tls_cert" {
  name         = "vault-cert"
  key_vault_id = data.azurerm_key_vault.vault.id
}

data "azurerm_key_vault_secret" "vault_tls_key" {
  name         = "vault-privkey"
  key_vault_id = data.azurerm_key_vault.vault.id
}

data "azurerm_key_vault_secret" "vault_tls_ca" {
  name         = "vault-ca-bundle"
  key_vault_id = data.azurerm_key_vault.vault.id
}

module "vault_primary" {
  source = "<path-or-registry-source-to-terraform-azurerm-vault-enterprise-hvd>"

  friendly_name_prefix = "vaultpri"
  location             = azurerm_resource_group.primary.location
  resource_group_name  = azurerm_resource_group.primary.name

  vnet_id        = azurerm_virtual_network.primary.id
  vault_subnet_id = azurerm_subnet.primary_vault.id
  lb_subnet_id    = azurerm_subnet.primary_lb.id

  vault_fqdn                          = "vault-primary.vault.internal.example.com"
  create_lb                           = true
  lb_is_internal                      = true
  lb_private_ip                       = "10.10.1.20"
  enable_vault_cluster_port_listener  = true

  create_vault_private_dns_record   = true
  private_dns_zone_name             = azurerm_private_dns_zone.vault.name
  private_dns_zone_rg               = azurerm_resource_group.network.name
  create_private_dns_zone_vnet_link = false
  vm_domain_suffix                  = azurerm_private_dns_zone.vault.name

  prereqs_keyvault_name                 = data.azurerm_key_vault.vault.name
  prereqs_keyvault_rg_name              = "rg-vault-shared"
  vault_license_keyvault_secret_id      = data.azurerm_key_vault_secret.vault_license.versionless_id
  vault_tls_cert_keyvault_secret_id     = data.azurerm_key_vault_secret.vault_tls_cert.versionless_id
  vault_tls_privkey_keyvault_secret_id  = data.azurerm_key_vault_secret.vault_tls_key.versionless_id
  vault_tls_ca_bundle_keyvault_secret_id = data.azurerm_key_vault_secret.vault_tls_ca.versionless_id

  vault_seal_azurekeyvault_vault_name      = data.azurerm_key_vault.vault.name
  vault_seal_azurekeyvault_unseal_key_name = "vault-unseal-key"
}

module "vault_secondary" {
  source = "<path-or-registry-source-to-terraform-azurerm-vault-enterprise-hvd>"

  friendly_name_prefix = "vaultsec"
  location             = azurerm_resource_group.secondary.location
  resource_group_name  = azurerm_resource_group.secondary.name

  vnet_id         = azurerm_virtual_network.secondary.id
  vault_subnet_id = azurerm_subnet.secondary_vault.id
  lb_subnet_id    = azurerm_subnet.secondary_lb.id

  vault_fqdn                         = "vault-secondary.vault.internal.example.com"
  create_lb                          = true
  lb_is_internal                     = true
  lb_private_ip                      = "10.20.1.20"
  enable_vault_cluster_port_listener = true

  create_vault_private_dns_record   = true
  private_dns_zone_name             = azurerm_private_dns_zone.vault.name
  private_dns_zone_rg               = azurerm_resource_group.network.name
  create_private_dns_zone_vnet_link = false
  vm_domain_suffix                  = azurerm_private_dns_zone.vault.name

  prereqs_keyvault_name                  = data.azurerm_key_vault.vault.name
  prereqs_keyvault_rg_name               = "rg-vault-shared"
  vault_license_keyvault_secret_id       = data.azurerm_key_vault_secret.vault_license.versionless_id
  vault_tls_cert_keyvault_secret_id      = data.azurerm_key_vault_secret.vault_tls_cert.versionless_id
  vault_tls_privkey_keyvault_secret_id   = data.azurerm_key_vault_secret.vault_tls_key.versionless_id
  vault_tls_ca_bundle_keyvault_secret_id = data.azurerm_key_vault_secret.vault_tls_ca.versionless_id

  vault_seal_azurekeyvault_vault_name      = data.azurerm_key_vault.vault.name
  vault_seal_azurekeyvault_unseal_key_name = "vault-unseal-key"
}
```

## DNS and certificate guidance

For replication, make sure the certificate presented by each node is trusted by the peer cluster.

At minimum, your TLS strategy should cover:

- `vault-primary.vault.internal.example.com`
- `vault-secondary.vault.internal.example.com`
- the VM hostnames created by each cluster when `vm_domain_suffix = "vault.internal.example.com"`

In practice, operators commonly use either:

- a wildcard certificate for the shared private zone, or
- a certificate with SANs that include both cluster FQDNs and the VM hostnames

## Enabling Vault DR replication

After both clusters are deployed, initialize them and then enable DR replication.

On the primary cluster:

```bash
vault operator init

vault write -f sys/replication/dr/primary/enable \
  primary_cluster_addr="https://vault-primary.vault.internal.example.com:8201"

vault write sys/replication/dr/primary/secondary-token \
  id="dr-secondary"
```

On the secondary cluster:

```bash
vault operator init

vault write sys/replication/dr/secondary/enable \
  token="<wrapping-token-from-primary>" \
  primary_api_addr="https://vault-primary.vault.internal.example.com:8200" \
  ca_file="/etc/vault.d/tls/ca.pem"
```

The `ca_file` parameter is important when the secondary connects to the primary through the load balancer FQDN instead of a certificate chain already trusted by the host operating system.

## Verifying replication

Use the replication status endpoint on both clusters:

```bash
vault read sys/replication/dr/status
```

For a healthy DR relationship you should see:

- the primary reporting `mode = "primary"`
- the secondary reporting `mode = "secondary"`
- the secondary reporting `connection_state = "ready"` and `state = "stream-wals"`
- the primary showing a connected secondary
- the primary `primary_cluster_addr` set to the load-balanced `8201` address

> 📝 Note: Testing an Azure internal load balancer from a node behind that same load balancer can be misleading. If you need to verify the listener directly, test from the peer VNet or rely on Vault replication status and connected heartbeats rather than a same-node curl.
