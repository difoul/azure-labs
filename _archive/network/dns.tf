resource "azurerm_private_dns_zone" "difoul-io" {
  name                = "difoul.io"
  resource_group_name = azurerm_resource_group.shared-services-rg.name
}

# resource "azurerm_private_dns_zone_virtual_network_link" "difoul-io-to-hub" {
#   name                  = "difoul-io-to-hub"
#   private_dns_zone_name = azurerm_private_dns_zone.difoul-io.name
#   resource_group_name   = azurerm_resource_group.shared-services-rg.name
#   virtual_network_id    = azurerm_virtual_network.hub.id
# }
#
# resource "azurerm_private_dns_zone_virtual_network_link" "difoul-io-to-spoke-01" {
#   name                  = "difoul-io-to-spoke-01"
#   private_dns_zone_name = azurerm_private_dns_zone.difoul-io.name
#   resource_group_name   = azurerm_resource_group.shared-services-rg.name
#   virtual_network_id    = azurerm_virtual_network.spoke-01.id
# }
#
# resource "azurerm_private_dns_zone_virtual_network_link" "difoul-io-to-spoke-02" {
#   name                  = "difoul-io-to-spoke-02"
#   private_dns_zone_name = azurerm_private_dns_zone.difoul-io.name
#   resource_group_name   = azurerm_resource_group.shared-services-rg.name
#   virtual_network_id    = azurerm_virtual_network.spoke-02.id
# }
#
# resource "azurerm_private_dns_zone_virtual_network_link" "difoul-io-to-spoke-03" {
#   name                  = "difoul-io-to-spoke-03"
#   private_dns_zone_name = azurerm_private_dns_zone.difoul-io.name
#   resource_group_name   = azurerm_resource_group.shared-services-rg.name
#   virtual_network_id    = azurerm_virtual_network.spoke-03.id
# }

resource "azurerm_private_dns_zone_virtual_network_link" "difoul-io-to-shared-services" {
  name                  = "difoul-io-to-shared-services"
  private_dns_zone_name = azurerm_private_dns_zone.difoul-io.name
  resource_group_name   = azurerm_resource_group.shared-services-rg.name
  virtual_network_id    = azurerm_virtual_network.shared-services.id
}

resource "azurerm_private_dns_resolver" "global-dns-resolver" {
  name                = "global-dns-resolver"
  resource_group_name = azurerm_resource_group.shared-services-rg.name
  location            = azurerm_resource_group.shared-services-rg.location
  virtual_network_id  = azurerm_virtual_network.shared-services.id

  tags = var.tags
}


resource "azurerm_private_dns_resolver_inbound_endpoint" "global-dns-resolver-inbound-edtp" {
  name                    = "global-dns-resolver-inbound-edtp"
  private_dns_resolver_id = azurerm_private_dns_resolver.global-dns-resolver.id
  location                = azurerm_private_dns_resolver.global-dns-resolver.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.inbound-edpt-shared-services.id
  }
  tags = var.tags
}


resource "azurerm_private_dns_resolver_outbound_endpoint" "global-dns-resolver-outbound-edtp" {
  name                    = "global-dns-resolver-outbound-edtp"
  private_dns_resolver_id = azurerm_private_dns_resolver.global-dns-resolver.id
  location                = azurerm_private_dns_resolver.global-dns-resolver.location
  subnet_id               = azurerm_subnet.outbound-edpt-shared-services.id

  tags = var.tags
}


resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "global-fwd-rules-set" {
  name                                       = "global-fw-rules-set"
  resource_group_name                        = azurerm_resource_group.shared-services-rg.name
  location                                   = azurerm_resource_group.shared-services-rg.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.global-dns-resolver-outbound-edtp.id]

  tags = var.tags
}

resource "azurerm_private_dns_resolver_virtual_network_link" "dns-rule-set-to-spoke-01" {
  name                      = "dns-rule-set-to-spoke-01"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.global-fwd-rules-set.id
  virtual_network_id        = azurerm_virtual_network.spoke-01.id

  metadata = {
    key = "value"
  }

}

resource "azurerm_private_dns_resolver_virtual_network_link" "dns-rule-set-to-spoke-02" {
  name                      = "dns-rule-set-to-spoke-02"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.global-fwd-rules-set.id
  virtual_network_id        = azurerm_virtual_network.spoke-02.id

  metadata = {
    key = "value"
  }

}

resource "azurerm_private_dns_resolver_virtual_network_link" "dns-rule-set-to-spoke-03" {
  name                      = "dns-rule-set-to-spoke-03"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.global-fwd-rules-set.id
  virtual_network_id        = azurerm_virtual_network.spoke-03.id

  metadata = {
    key = "value"
  }

}

resource "azurerm_private_dns_resolver_forwarding_rule" "rule-global" {
  name                      = "global"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.global-fwd-rules-set.id
  domain_name               = "difoul.io."
  enabled                   = true
  target_dns_servers {
    ip_address = azurerm_private_dns_resolver_inbound_endpoint.global-dns-resolver-inbound-edtp.ip_configurations[0].private_ip_address
    port       = 53
  }
  metadata = {
    key = "value"
  }
}

#######################

resource "azurerm_private_dns_zone" "app02-difoul-io" {
  name                = "app.difoul.io"
  resource_group_name = azurerm_resource_group.spoke-02-rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "app02-difoul-io-to-hub" {
  name                  = "app02-difoul-io-to-hub"
  private_dns_zone_name = azurerm_private_dns_zone.app02-difoul-io.name
  resource_group_name   = azurerm_resource_group.spoke-02-rg.name
  virtual_network_id    = azurerm_virtual_network.spoke-02.id
}

resource "azurerm_private_dns_resolver" "app02-dns-resolver" {
  name                = "app-dns-resolver"
  resource_group_name = azurerm_resource_group.spoke-02-rg.name
  location            = azurerm_resource_group.spoke-02-rg.location
  virtual_network_id  = azurerm_virtual_network.spoke-02.id

  tags = var.tags
}


resource "azurerm_private_dns_resolver_inbound_endpoint" "app02-dns-resolver-inbound-edtp" {
  name                    = "app02-dns-resolver-inbound-edtp"
  private_dns_resolver_id = azurerm_private_dns_resolver.app02-dns-resolver.id
  location                = azurerm_private_dns_resolver.app02-dns-resolver.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.inbound-edpt-spoke-02.id
  }
  tags = var.tags
}


resource "azurerm_private_dns_resolver_outbound_endpoint" "app02-dns-resolver-outbound-edtp" {
  name                    = "app02-dns-resolver-outbound-edtp"
  private_dns_resolver_id = azurerm_private_dns_resolver.app02-dns-resolver.id
  location                = azurerm_private_dns_resolver.app02-dns-resolver.location
  subnet_id               = azurerm_subnet.outbound-edpt-spoke-02.id

  tags = var.tags
}



resource "azurerm_private_dns_resolver_forwarding_rule" "rule-app02" {
  name                      = "app02"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.global-fwd-rules-set.id
  domain_name               = "app.difoul.io."
  enabled                   = true
  target_dns_servers {
    ip_address = azurerm_private_dns_resolver_inbound_endpoint.app02-dns-resolver-inbound-edtp.ip_configurations[0].private_ip_address
    port       = 53
  }
  metadata = {
    key = "value"
  }
}


#
#
# resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "app02-fwd-rules-set" {
#   name                                       = "app02-fw-rules-set"
#   resource_group_name                        = azurerm_resource_group.spoke-02-rg.name
#   location                                   = azurerm_resource_group.spoke-02-rg.location
#   private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.app02-dns-resolver-outbound-edtp.id]
#
#   tags = var.tags
# }
#
# resource "azurerm_private_dns_resolver_virtual_network_link" "app-02-dns-rule-set-to-spoke-02" {
#   name                      = "app-02-dns-rule-set-to-spoke-02"
#   dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.app02-fwd-rules-set.id
#   virtual_network_id        = azurerm_virtual_network.spoke-02.id
#
#   metadata = {
#     key = "value"
#   }
#
# }
#
# resource "azurerm_private_dns_resolver_forwarding_rule" "rule-app02-bis" {
#   name                      = "app02"
#   dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.app02-fwd-rules-set.id
#   domain_name               = "app.difoul.io."
#   enabled                   = true
#   target_dns_servers {
#     ip_address = azurerm_private_dns_resolver_inbound_endpoint.app02-dns-resolver-inbound-edtp.ip_configurations[0].private_ip_address
#     port       = 53
#   }
#   metadata = {
#     key = "value"
#   }
# }


################
resource "azurerm_private_dns_a_record" "vm" {
  name                = "vm"
  zone_name           = azurerm_private_dns_zone.app02-difoul-io.name
  resource_group_name = azurerm_resource_group.spoke-02-rg.name
  ttl                 = 300
  records             = ["10.2.0.4"]
}


resource "azurerm_private_dns_a_record" "bastion" {
  name                = "bastion"
  zone_name           = azurerm_private_dns_zone.difoul-io.name
  resource_group_name = azurerm_resource_group.shared-services-rg.name
  ttl                 = 300
  records             = ["10.2.0.4"]
}