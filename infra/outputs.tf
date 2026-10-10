output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "name_suffix" {
  value = random_string.suffix.result
}

output "swa_default_hostname" {
  value = azurerm_static_web_app.this.default_host_name
}

output "swa_deployment_token" {
  value     = azurerm_static_web_app.this.api_key
  sensitive = true
}