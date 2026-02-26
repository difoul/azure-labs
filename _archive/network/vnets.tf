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

resource "azurerm_subnet" "front_subnet-spoke-02" {
  name                 = "front-spk-02"
  resource_group_name  = azurerm_resource_group.spoke-02-rg.name
  virtual_network_name = azurerm_virtual_network.spoke-02.name
  address_prefixes     = ["10.2.1.0/24"]
}


resource "azurerm_subnet" "inbound-edpt-spoke-02" {
  name                 = "inbound-edpt"
  resource_group_name  = azurerm_resource_group.spoke-02-rg.name
  virtual_network_name = azurerm_virtual_network.spoke-02.name
  address_prefixes     = ["10.2.2.0/24"]

  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

resource "azurerm_subnet" "outbound-edpt-spoke-02" {
  name                 = "outbound-edpt"
  resource_group_name  = azurerm_resource_group.spoke-02-rg.name
  virtual_network_name = azurerm_virtual_network.spoke-02.name
  address_prefixes     = ["10.2.3.0/24"]

  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }

}


resource "azurerm_network_security_group" "spoke-02-app-nsg" {
  name                = "spoke-02-app-nsg"
  location            = azurerm_resource_group.spoke-02-rg.location
  resource_group_name = azurerm_resource_group.spoke-02-rg.name

  security_rule {
    name                         = "http"
    priority                     = 1000
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "80"
    source_address_prefixes      = ["10.1.0.0/24", "10.3.0.0/24"]
    destination_address_prefixes = ["10.2.0.0/24"]
  }

  security_rule {
    name                         = "allowLB"
    priority                     = 1100
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "80"
    source_address_prefix        = "AzureLoadBalancer"
    destination_address_prefixes = ["10.2.0.0/24"]
  }


  security_rule {
    name                       = "DenyAll"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  #  {
  #   - access                                     = "Allow"
  #   - destination_address_prefix                 = "VirtualNetwork"
  #   - destination_address_prefixes               = []
  #   - destination_application_security_group_ids = []
  #   - destination_port_range                     = "80"
  #   - destination_port_ranges                    = []
  #   - direction                                  = "Inbound"
  #   - name                                       = "allowInternal"
  #   - priority                                   = 1100
  #   - protocol                                   = "Tcp"
  #   - source_address_prefix                      = "AzureLoadBalancer"
  #   - source_address_prefixes                    = []
  #   - source_application_security_group_ids      = []
  #   - source_port_range                          = "*"
  #   - source_port_ranges                         = []
  #     # (1 unchanged attribute hidden)
  # }
  tags = var.tags
}


resource "azurerm_network_security_group" "spoke-02-default-nsg" {
  name                = "spoke-02-default-nsg"
  location            = azurerm_resource_group.spoke-02-rg.location
  resource_group_name = azurerm_resource_group.spoke-02-rg.name

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "main-to-app-spk02" {
  subnet_id                 = azurerm_subnet.main_subnet-spoke-02.id
  network_security_group_id = azurerm_network_security_group.spoke-02-app-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "front-to-app-spk02" {
  subnet_id                 = azurerm_subnet.front_subnet-spoke-02.id
  network_security_group_id = azurerm_network_security_group.spoke-02-app-nsg.id
}



resource "azurerm_subnet_network_security_group_association" "outbound-edpt-to-default-spk02" {
  subnet_id                 = azurerm_subnet.outbound-edpt-spoke-02.id
  network_security_group_id = azurerm_network_security_group.spoke-02-default-nsg.id
}



resource "azurerm_subnet_network_security_group_association" "inbound-edpt-to-default-spk02" {
  subnet_id                 = azurerm_subnet.inbound-edpt-spoke-02.id
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


# ###############################################
#
#       Shared-services
#
#################################################
resource "azurerm_virtual_network" "shared-services" {
  name                = "shared-services-${var.product-name}"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.shared-services-rg.location
  resource_group_name = azurerm_resource_group.shared-services-rg.name

  tags = var.tags
}

resource "azurerm_subnet" "inbound-edpt-shared-services" {
  name                 = "inbound-edpt"
  resource_group_name  = azurerm_resource_group.shared-services-rg.name
  virtual_network_name = azurerm_virtual_network.shared-services.name
  address_prefixes     = ["10.10.0.0/24"]

  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

resource "azurerm_subnet" "outbound-edpt-shared-services" {
  name                 = "outbound-edpt"
  resource_group_name  = azurerm_resource_group.shared-services-rg.name
  virtual_network_name = azurerm_virtual_network.shared-services.name
  address_prefixes     = ["10.10.1.0/24"]

  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }

}

# resource "azurerm_subnet" "bastion-shared-services" {
#   name                 = "AzureBastionSubnet"
#   resource_group_name  = azurerm_resource_group.shared-services-rg.name
#   virtual_network_name = azurerm_virtual_network.shared-services.name
#   address_prefixes     = ["10.10.2.0/24"]
# }


# resource "azurerm_subnet" "bastion-spoke-01" {
#   name                 = "AzureBastionSubnet"
#   resource_group_name  = azurerm_resource_group.spoke-01-rg.name
#   virtual_network_name = azurerm_virtual_network.spoke-01.name
#   address_prefixes     = ["10.1.3.0/24"]
# }


resource "azurerm_network_security_group" "shared-services-default-nsg" {
  name                = "shared-services-default-nsg"
  location            = azurerm_resource_group.shared-services-rg.location
  resource_group_name = azurerm_resource_group.shared-services-rg.name

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "main-to-default-shared-services" {
  subnet_id                 = azurerm_subnet.inbound-edpt-shared-services.id
  network_security_group_id = azurerm_network_security_group.shared-services-default-nsg.id
}


resource "azurerm_subnet_network_security_group_association" "outbound-edpt-to-default-shared-services" {
  subnet_id                 = azurerm_subnet.outbound-edpt-shared-services.id
  network_security_group_id = azurerm_network_security_group.shared-services-default-nsg.id
}

# resource "azurerm_subnet_network_security_group_association" "bastion-to-default-shared-services" {
#   subnet_id                 = azurerm_subnet.bastion-shared-services.id
#   network_security_group_id = azurerm_network_security_group.shared-services-default-nsg.id
# }
