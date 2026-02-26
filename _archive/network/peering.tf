resource "azurerm_virtual_network_peering" "hub_to_spoke-01" {
  name                      = "hub-to-spoke-01"
  resource_group_name       = azurerm_resource_group.hub-rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke-01.id
}

resource "azurerm_virtual_network_peering" "spoke-01_to_hub" {
  name                      = "spoke-01-to-hub"
  resource_group_name       = azurerm_resource_group.spoke-01-rg.name
  virtual_network_name      = azurerm_virtual_network.spoke-01.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "hub_to_spoke-02" {
  name                      = "hub-to-spoke-02"
  resource_group_name       = azurerm_resource_group.hub-rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke-02.id
}

resource "azurerm_virtual_network_peering" "spoke-02_to_hub" {
  name                      = "spoke-02-to-hub"
  resource_group_name       = azurerm_resource_group.spoke-02-rg.name
  virtual_network_name      = azurerm_virtual_network.spoke-02.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "hub_to_spoke-03" {
  name                      = "hub-to-spoke-03"
  resource_group_name       = azurerm_resource_group.hub-rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke-03.id
}

resource "azurerm_virtual_network_peering" "spoke-03_to_hub" {
  name                      = "spoke-03-to-hub"
  resource_group_name       = azurerm_resource_group.spoke-03-rg.name
  virtual_network_name      = azurerm_virtual_network.spoke-03.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "hub_to_shared-services" {
  name                      = "hub_to_shared-services"
  resource_group_name       = azurerm_resource_group.hub-rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.shared-services.id
}

resource "azurerm_virtual_network_peering" "shared-services_to_hub" {
  name                      = "shared-services_to_hub"
  resource_group_name       = azurerm_resource_group.shared-services-rg.name
  virtual_network_name      = azurerm_virtual_network.shared-services.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}
