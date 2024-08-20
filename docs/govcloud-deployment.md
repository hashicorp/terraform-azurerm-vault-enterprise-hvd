# Deploying in Azure Government Cloud

Normal Azure subscriptions are hosted in what Azure refers to as their _public_ environment (`AzureCloud`). Azure has also defined an environment they call _Azure Government_ (`AzureUSGovernment`). The separation of these environments means that some internal Azure API endpoints, DNS domains, and more will differ, which impacts some of the configuration setting values for a Vault deployment.

## Configuration Settings

This module includes an input variable of type boolean named `is_govcloud_region` that defaults to `false`. Setting this to `true` will change some of the domain names and endpoints to support deploying Vault in the Azure Government cloud environment as follows:

### AzureRM Provider Block

You will need to update the value of `environment` within your azurerm provider block within your root Terraform configuration that deploys this module to `usgovernment` like so:

```hcl
provider "azurerm" {
  environment = "usgovernment"
  features {}
}
```

### AzureRM Remote State Backend Configuration

You will need to ensure that you specify the `environment` key within your AzureRM remote state backend configuration with a value of `usgovernment` like so:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "StorageAccount-ResourceGroup"
    storage_account_name = "abcd1234"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    environment          = usgovernment
  }
}
```
