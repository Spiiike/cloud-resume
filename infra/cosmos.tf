resource "azurerm_cosmosdb_account" "this" {
  name                = "cosmos-${var.project}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = "eastus2"
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableTable"
  }

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = "eastus2"
    failover_priority = 0
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_table" "counter" {
  name                = "counter"
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
}

locals {
  cosmos_table_connection_string = join("", [
    "DefaultEndpointsProtocol=https;",
    "AccountName=${azurerm_cosmosdb_account.this.name};",
    "AccountKey=${azurerm_cosmosdb_account.this.primary_key};",
    "TableEndpoint=https://${azurerm_cosmosdb_account.this.name}.table.cosmos.azure.com:443/;"
  ])
}