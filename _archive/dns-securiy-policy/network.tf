resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "rg-${var.product-name}"
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "hub-${var.product-name}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_subnet" "inbound-edpt-hub" {
  name                 = "inbound-edpt"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/24"]

  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

resource "azurerm_subnet" "outbound-edpt-hub" {
  name                 = "outbound-edpt"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }

}


resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr-to-hub" {
  name                  = "acr-to-hub"
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}


resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv-to-hub" {
  name                  = "kv-to-hub"
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone" "difoul-io" {
  name                = "difoul.io"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "difoul-io-to-hub" {
  name                  = "difoul-io-to-hub"
  private_dns_zone_name = azurerm_private_dns_zone.difoul-io.name
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}


resource "azurerm_private_dns_resolver" "global-dns-resolver" {
  name                = "global-dns-resolver"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  virtual_network_id  = azurerm_virtual_network.hub.id

  tags = var.tags
}


resource "azurerm_private_dns_resolver_inbound_endpoint" "global-dns-resolver-inbound-edtp" {
  name                    = "global-dns-resolver-inbound-edtp"
  private_dns_resolver_id = azurerm_private_dns_resolver.global-dns-resolver.id
  location                = azurerm_private_dns_resolver.global-dns-resolver.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.inbound-edpt-hub.id
  }
  tags = var.tags
}


resource "azurerm_private_dns_resolver_outbound_endpoint" "global-dns-resolver-outbound-edtp" {
  name                    = "global-dns-resolver-outbound-edtp"
  private_dns_resolver_id = azurerm_private_dns_resolver.global-dns-resolver.id
  location                = azurerm_private_dns_resolver.global-dns-resolver.location
  subnet_id               = azurerm_subnet.outbound-edpt-hub.id

  tags = var.tags
}


resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "global-fwd-rules-set" {
  name                                       = "global-fw-rules-set"
  resource_group_name                        = azurerm_resource_group.rg.name
  location                                   = azurerm_resource_group.rg.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.global-dns-resolver-outbound-edtp.id]

  tags = var.tags
}



# ###############################################
#
#       Spoke 01
#
#################################################
resource "azurerm_virtual_network" "spoke-01" {
  name                = "spoke-01-${var.product-name}"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_servers         = [azurerm_private_dns_resolver_inbound_endpoint.global-dns-resolver-inbound-edtp.ip_configurations[0].private_ip_address]

  tags = var.tags
}

resource "azurerm_subnet" "main_subnet-spoke-01" {
  name                 = "main-spk-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke-01.name
  address_prefixes     = ["10.1.0.0/24"]
}



# ###############################################
#
#       Peering
#
#################################################
resource "azurerm_virtual_network_peering" "hub_to_spoke-01" {
  name                      = "hub-to-spoke-01"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke-01.id
}

resource "azurerm_virtual_network_peering" "spoke-01_to_hub" {
  name                      = "spoke-01-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.spoke-01.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}



# ###############################################
#
#       Bastion
#
#################################################
resource "azurerm_bastion_host" "bastion" {
  name                = "bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Developer"

  virtual_network_id = azurerm_virtual_network.spoke-01.id

}