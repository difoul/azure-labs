resource "azurerm_route_table" "to-hub-rt" {
  location                      = azurerm_resource_group.hub-rg.location
  name                          = "to-hub-rt-${var.product-name}"
  resource_group_name           = azurerm_resource_group.hub-rg.name
  bgp_route_propagation_enabled = false

  route {
    name                   = "to-hub"
    address_prefix         = "10.0.0.0/8" # "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }

  tags = var.tags
}

resource "azurerm_route_table" "to-internet-rt" {
  location            = azurerm_resource_group.hub-rg.location
  name                = "to-internet-rt-${var.product-name}"
  resource_group_name = azurerm_resource_group.hub-rg.name

  route {
    name           = "to-hub"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = var.tags
}


resource "azurerm_subnet_route_table_association" "firewall_subnet-rta" {
  subnet_id      = azurerm_subnet.firewall_subnet.id
  route_table_id = azurerm_route_table.to-internet-rt.id
}


resource "azurerm_subnet_route_table_association" "main_subnet-spoke-01-rta" {
  subnet_id      = azurerm_subnet.main_subnet-spoke-01.id
  route_table_id = azurerm_route_table.to-hub-rt.id
}


resource "azurerm_subnet_route_table_association" "webapp_subnet-spoke-01-rta" {
  subnet_id      = azurerm_subnet.webapp_subnet-spoke-01.id
  route_table_id = azurerm_route_table.to-hub-rt.id
}


resource "azurerm_subnet_route_table_association" "endpoint-spoke-01-rta" {
  subnet_id      = azurerm_subnet.endpoint-spoke-01.id
  route_table_id = azurerm_route_table.to-hub-rt.id
}


resource "azurerm_subnet_route_table_association" "main_subnet-spoke-02-rta" {
  subnet_id      = azurerm_subnet.main_subnet-spoke-02.id
  route_table_id = azurerm_route_table.to-hub-rt.id
}


resource "azurerm_subnet_route_table_association" "front_subnet-spoke-02-rta" {
  subnet_id      = azurerm_subnet.front_subnet-spoke-02.id
  route_table_id = azurerm_route_table.to-hub-rt.id
}


resource "azurerm_subnet_route_table_association" "main_subnet-spoke-03-rta" {
  subnet_id      = azurerm_subnet.main_subnet-spoke-03.id
  route_table_id = azurerm_route_table.to-hub-rt.id
}