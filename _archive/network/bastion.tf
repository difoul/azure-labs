resource "azurerm_bastion_host" "bastion" {
  name                = "bastion"
  location            = azurerm_resource_group.shared-services-rg.location
  resource_group_name = azurerm_resource_group.shared-services-rg.name
  sku                 = "Developer"

  virtual_network_id = azurerm_virtual_network.spoke-01.id

  # ip_configuration {
  #   name                 = "configuration"
  #   subnet_id            = azurerm_subnet.bastion-spoke-01.id
  #   public_ip_address_id = azurerm_public_ip.bastion-pub-ip.id
  # }
}


resource "azurerm_public_ip" "bastion-pub-ip" {
  name                = "bastion-pub-ip-${var.product-name}"
  allocation_method   = "Static"
  location            = azurerm_resource_group.shared-services-rg.location
  resource_group_name = azurerm_resource_group.shared-services-rg.name
  sku                 = "Standard"

  tags = var.tags
}