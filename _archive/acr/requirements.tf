resource "azurerm_resource_group" "acr" {
  location = var.location
  name     = "rg-acr-${var.product-name}"
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "hub-${var.product-name}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.acr.location
  resource_group_name = azurerm_resource_group.acr.name

  tags = var.tags
}

resource "azurerm_subnet" "endpoints" {
  name                 = "endpoints"
  resource_group_name  = azurerm_resource_group.acr.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/24"]
}


resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.acr.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr-to-hub" {
  name                  = "acr-to-hub"
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  resource_group_name   = azurerm_resource_group.acr.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

resource "azurerm_user_assigned_identity" "acr" {
  location            = azurerm_resource_group.acr.location
  name                = "acr-id"
  resource_group_name = azurerm_resource_group.acr.name
}

# RBAC assignments
resource "azurerm_role_assignment" "acr" {
  scope                = azurerm_key_vault.acr.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.acr.principal_id
  depends_on           = [azurerm_private_endpoint.pe_kv]
}

resource "time_sleep" "wait_for_rbac_acr" {
  depends_on      = [azurerm_role_assignment.acr]
  create_duration = "60s"
}


resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.acr.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv-to-hub" {
  name                  = "kv-to-hub"
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  resource_group_name   = azurerm_resource_group.acr.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}