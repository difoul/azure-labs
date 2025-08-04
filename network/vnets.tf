# ###############################################
#
#       Network watcher
#
#################################################


resource "azurerm_network_watcher" "network-watcher" {
  location            = azurerm_resource_group.network-watcher-rg.location
  name                = "network-watcher-${var.product-name}"
  resource_group_name = azurerm_resource_group.network-watcher-rg.name
  tags                = var.tags
}


# ###############################################
#
#       HUB
#
#################################################
resource "azurerm_virtual_network" "hub" {
  name                = "hub-${var.product-name}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name

  tags = var.tags
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub-rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/24"]
}


# ###############################################
#
#       Spoke 01
#
#################################################
resource "azurerm_virtual_network" "spoke-01" {
  name                = "spoke-01-${var.product-name}"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.spoke-01-rg.location
  resource_group_name = azurerm_resource_group.spoke-01-rg.name

  tags = var.tags
}

resource "azurerm_subnet" "main_subnet-spoke-01" {
  name                 = "main-spk-01"
  resource_group_name  = azurerm_resource_group.spoke-01-rg.name
  virtual_network_name = azurerm_virtual_network.spoke-01.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_subnet" "webapp_subnet-spoke-01" {
  name                 = "web-spk-01"
  resource_group_name  = azurerm_resource_group.spoke-01-rg.name
  virtual_network_name = azurerm_virtual_network.spoke-01.name
  address_prefixes     = ["10.1.1.0/24"]
  delegation {
    name = "webapp"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "endpoint-spoke-01" {
  name                              = "endpoint-spk-01"
  resource_group_name               = azurerm_resource_group.spoke-01-rg.name
  virtual_network_name              = azurerm_virtual_network.spoke-01.name
  address_prefixes                  = ["10.1.2.0/24"]
  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_network_security_group" "spoke-01-default-nsg" {
  name                = "spoke-01-default-nsg"
  location            = azurerm_resource_group.spoke-01-rg.location
  resource_group_name = azurerm_resource_group.spoke-01-rg.name

  security_rule {
    name                       = "allow-all-from-my-pub-ip"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.my-public-ip
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "main-to-default-spk01" {
  subnet_id                 = azurerm_subnet.main_subnet-spoke-01.id
  network_security_group_id = azurerm_network_security_group.spoke-01-default-nsg.id
}

# ###############################################
#
#       Spoke 02
#
#################################################
resource "azurerm_virtual_network" "spoke-02" {
  name                = "spoke-02-${var.product-name}"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.spoke-02-rg.location
  resource_group_name = azurerm_resource_group.spoke-02-rg.name

  tags = var.tags
}

resource "azurerm_subnet" "main_subnet-spoke-02" {
  name                 = "main-spk-02"
  resource_group_name  = azurerm_resource_group.spoke-02-rg.name
  virtual_network_name = azurerm_virtual_network.spoke-02.name
  address_prefixes     = ["10.2.0.0/24"]
}


resource "azurerm_network_security_group" "spoke-02-default-nsg" {
  name                = "spoke-02-default-nsg"
  location            = azurerm_resource_group.spoke-02-rg.location
  resource_group_name = azurerm_resource_group.spoke-02-rg.name

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "main-to-default-spk02" {
  subnet_id                 = azurerm_subnet.main_subnet-spoke-02.id
  network_security_group_id = azurerm_network_security_group.spoke-02-default-nsg.id
}
# ###############################################
#
#       Spoke 03
#
#################################################
resource "azurerm_virtual_network" "spoke-03" {
  name                = "spoke-03-${var.product-name}"
  address_space       = ["10.3.0.0/16"]
  location            = azurerm_resource_group.spoke-03-rg.location
  resource_group_name = azurerm_resource_group.spoke-03-rg.name

  tags = var.tags
}

resource "azurerm_subnet" "main_subnet-spoke-03" {
  name                 = "main-spk-03"
  resource_group_name  = azurerm_resource_group.spoke-03-rg.name
  virtual_network_name = azurerm_virtual_network.spoke-03.name
  address_prefixes     = ["10.3.0.0/24"]
}



resource "azurerm_network_security_group" "spoke-03-default-nsg" {
  name                = "spoke-03-default-nsg"
  location            = azurerm_resource_group.spoke-03-rg.location
  resource_group_name = azurerm_resource_group.spoke-03-rg.name

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "main-to-default-spk03" {
  subnet_id                 = azurerm_subnet.main_subnet-spoke-03.id
  network_security_group_id = azurerm_network_security_group.spoke-03-default-nsg.id
}

