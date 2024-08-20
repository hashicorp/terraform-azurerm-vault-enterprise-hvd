resource "azurerm_resource_group" "vault" {
  count = var.create_resource_group == true ? 1 : 0

  name     = var.resource_group_name
  location = var.location

  tags = merge(
    { "Name" = var.resource_group_name },
    var.common_tags
  )
}

data "azurerm_resource_group" "vault" {
  count = var.create_resource_group == true ? 0 : 1

  name = var.resource_group_name
}
