resource "azurerm_public_ip" "fw-pub-ip" {
  name                = "fw-pub-ip-${var.product-name}"
  allocation_method   = "Static"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_firewall" "firewall" {
  location            = azurerm_resource_group.hub-rg.location
  name                = "firewall-${var.product-name}"
  resource_group_name = azurerm_resource_group.hub-rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "fw-ip-configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.fw-pub-ip.id
  }

  firewall_policy_id = azurerm_firewall_policy.fw-policy.id

  tags = var.tags
}

resource "azurerm_firewall_policy" "fw-policy" {
  location            = azurerm_resource_group.hub-rg.location
  name                = "fw-policy-${var.product-name}"
  resource_group_name = azurerm_resource_group.hub-rg.name

  tags = var.tags
}


resource "azurerm_firewall_policy_rule_collection_group" "fw-policy-default-crg" {
  name               = "fw-policy-default-crg"
  firewall_policy_id = azurerm_firewall_policy.fw-policy.id
  priority           = 1000
  # application_rule_collection {
  #   name     = "app_rule_collection1"
  #   priority = 500
  #   action   = "Deny"
  #   rule {
  #     name = "app_rule_collection1_rule1"
  #     protocols {
  #       type = "Http"
  #       port = 80
  #     }
  #     protocols {
  #       type = "Https"
  #       port = 443
  #     }
  #     source_addresses  = ["10.0.0.1"]
  #     destination_fqdns = ["*.microsoft.com"]
  #   }
  # }

  network_rule_collection {
    name     = "vms_rule_collection"
    priority = 400
    action   = "Allow"
    # rule {
    #   name                  = "allow_http"
    #   protocols             = ["TCP", "UDP"]
    #   source_addresses      = ["10.1.0.0/24","10.2.0.0/24","10.3.0.0/24"]
    #   destination_addresses = ["10.1.0.0/24","10.2.0.0/24","10.3.0.0/24"]
    #   destination_ports     = ["80"]
    # }
    rule {
      name                  = "allow_http"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }

  # nat_rule_collection {
  #   name     = "nat_rule_collection1"
  #   priority = 300
  #   action   = "Dnat"
  #   rule {
  #     name                = "nat_rule_collection1_rule1"
  #     protocols           = ["TCP", "UDP"]
  #     source_addresses    = ["10.0.0.1", "10.0.0.2"]
  #     destination_address = "192.168.1.1"
  #     destination_ports   = ["80"]
  #     translated_address  = "192.168.0.1"
  #     translated_port     = "8080"
  #   }
  # }
}
