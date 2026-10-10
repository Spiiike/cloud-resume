resource "azurerm_static_web_app" "this" {
  name                = "swa-${var.project}-${random_string.suffix.result}"
resource_group_name = azurerm_resource_group.this.name
  location            = var.swa_location
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = var.tags
}