output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "name_suffix" {
  value = random_string.suffix.result
}