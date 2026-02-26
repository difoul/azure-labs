# -------------------------------------------------------
# Private DNS Zone for ACR
# -------------------------------------------------------

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.acr.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_to_hub" {
  name                  = "acr-to-hub"
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  resource_group_name   = azurerm_resource_group.acr.name
  virtual_network_id    = var.hub_vnet_id
}
