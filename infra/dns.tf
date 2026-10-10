data "azurerm_dns_zone" "this" {
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group
}

resource "azurerm_static_web_app_custom_domain" "apex" {
  static_web_app_id = azurerm_static_web_app.this.id
  domain_name       = var.domain_name
  validation_type   = "dns-txt-token"
}

resource "azurerm_dns_txt_record" "apex_validation" {
  name                = "_dnsauth"
  zone_name           = data.azurerm_dns_zone.this.name
  resource_group_name = var.dns_zone_resource_group
  ttl                 = 300

  record {
    value = coalesce(
      azurerm_static_web_app_custom_domain.apex.validation_token,
      "validated"
    )
  }

  lifecycle {
    ignore_changes = [record]
  }
}

resource "azurerm_dns_a_record" "apex" {
  name                = "@"
  zone_name           = data.azurerm_dns_zone.this.name
  resource_group_name = var.dns_zone_resource_group
  ttl                 = 300
  target_resource_id  = azurerm_static_web_app.this.id
}

resource "azurerm_dns_cname_record" "www" {
  name                = "www"
  zone_name           = data.azurerm_dns_zone.this.name
  resource_group_name = data.azurerm_dns_zone.this.resource_group_name
  ttl                 = 300
  record              = azurerm_static_web_app.this.default_host_name
}

resource "azurerm_static_web_app_custom_domain" "www" {
  static_web_app_id = azurerm_static_web_app.this.id
  domain_name = "${azurerm_dns_cname_record.www.name}.${azurerm_dns_cname_record.www.zone_name}"
  validation_type = "cname-delegation"
}