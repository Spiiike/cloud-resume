# test


resource "random_string" "suffix" {
  length  = 4
  lower   = true
  numeric = true
  upper   = false
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.project}"
  location = var.location
  tags     = var.tags
}
