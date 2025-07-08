locals {
  default_tags = {
    "environment" = title(var.environment)
    # "team"        = var.team
    "terraform"   = "true"
    # "product"     = var.product
  }

  all_tags =  merge(local.default_tags, var.tags)
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-pk-${var.app_name}-${var.environment}-${var.location}-${var.instance_number}"
  location = var.location
  tags     = local.all_tags
}