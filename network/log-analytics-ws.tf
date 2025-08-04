resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.product-name}"
  location            = azurerm_resource_group.law-rg.location
  resource_group_name = azurerm_resource_group.law-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}