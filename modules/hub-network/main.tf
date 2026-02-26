locals {
  # Subnets are needed by both enable_dns_resolver_subnets (external resolver, e.g. dns-security module)
  # and enable_dns_resolver (hub-owned resolver). Gate on either flag.
  create_dns_subnets = var.enable_dns_resolver_subnets || var.enable_dns_resolver
}

# -------------------------------------------------------
# Resource Group
# -------------------------------------------------------

resource "azurerm_resource_group" "hub" {
  location = var.location
  name     = "rg-hub-${var.product-name}"
  tags     = var.tags
}

# -------------------------------------------------------
# Network Watcher
# -------------------------------------------------------

resource "azurerm_network_watcher" "this" {
  location            = azurerm_resource_group.hub.location
  name                = "network-watcher-${var.product-name}"
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags
}

# -------------------------------------------------------
# Hub VNet + Subnets
# -------------------------------------------------------

resource "azurerm_virtual_network" "hub" {
  name                = "hub-${var.product-name}"
  address_space       = [var.hub_address_space]
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.firewall_subnet_cidr]
}

resource "azurerm_subnet" "endpoints" {
  name                 = "endpoints"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.endpoint_subnet_cidr]
}

resource "azurerm_subnet" "dns_inbound" {
  count                = local.create_dns_subnets ? 1 : 0
  name                 = "dns-inbound"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.inbound_dns_subnet_cidr]

  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

resource "azurerm_subnet" "dns_outbound" {
  count                = local.create_dns_subnets ? 1 : 0
  name                 = "dns-outbound"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.outbound_dns_subnet_cidr]

  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}


# -------------------------------------------------------
# Azure Firewall
# -------------------------------------------------------

resource "azurerm_public_ip" "firewall" {
  name                = "fw-pub-ip-${var.product-name}"
  allocation_method   = "Static"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy" "this" {
  location            = azurerm_resource_group.hub.location
  name                = "fw-policy-${var.product-name}"
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "default" {
  name               = "fw-policy-default-rcg"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 1000

  network_rule_collection {
    name     = "allow-all-internal"
    priority = 400
    action   = "Allow"

    rule {
      name                  = "allow-all"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }

  application_rule_collection {
    name     = "allow-web"
    priority = 500
    action   = "Allow"

    rule {
      name = "allow-microsoft"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["10.0.0.0/8"]
      destination_fqdns = ["*.microsoft.com"]
    }
  }
}

resource "azurerm_firewall" "this" {
  location            = azurerm_resource_group.hub.location
  name                = "firewall-${var.product-name}"
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "fw-ip-configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  firewall_policy_id = azurerm_firewall_policy.this.id
  tags               = var.tags
}

# -------------------------------------------------------
# Log Analytics Workspace
# -------------------------------------------------------

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.product-name}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# -------------------------------------------------------
# Firewall Diagnostic Settings
# -------------------------------------------------------

data "azurerm_monitor_diagnostic_categories" "firewall" {
  resource_id = azurerm_firewall.this.id
}

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                           = "firewall-diagnostics"
  target_resource_id             = azurerm_firewall.this.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.this.id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.firewall.metrics
    content {
      category = enabled_metric.value
    }
  }

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.firewall.log_category_types
    content {
      category = enabled_log.value
    }
  }
}

# -------------------------------------------------------
# Azure Bastion (optional, Developer SKU)
# -------------------------------------------------------

resource "azurerm_bastion_host" "this" {
  count               = var.enable_bastion ? 1 : 0
  name                = "bastion-${var.product-name}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Developer"
  virtual_network_id  = azurerm_virtual_network.hub.id
  tags                = var.tags
}

# -------------------------------------------------------
# VNet Flow Logs (optional)
# -------------------------------------------------------

resource "random_integer" "storage_suffix" {
  count = var.enable_flow_logs ? 1 : 0
  min   = 10000
  max   = 99999
}

resource "azurerm_storage_account" "flow_logs" {
  count                    = var.enable_flow_logs ? 1 : 0
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.hub.location
  name                     = "nwsto${random_integer.storage_suffix[0].result}${var.product-name}"
  resource_group_name      = azurerm_resource_group.hub.name
  tags                     = var.tags
}

resource "azurerm_network_watcher_flow_log" "hub" {
  count                = var.enable_flow_logs ? 1 : 0
  enabled              = true
  name                 = "vnet-flow-log-hub"
  network_watcher_name = azurerm_network_watcher.this.name
  resource_group_name  = azurerm_resource_group.hub.name
  storage_account_id   = azurerm_storage_account.flow_logs[0].id
  target_resource_id   = azurerm_virtual_network.hub.id

  retention_policy {
    days    = 7
    enabled = true
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.this.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.this.location
    workspace_resource_id = azurerm_log_analytics_workspace.this.id
    interval_in_minutes   = 10
  }
}

# -------------------------------------------------------
# Private DNS Resolver (optional, hub-owned)
#
# Enabled via enable_dns_resolver = true.
# Spokes point their dns_servers to the inbound endpoint IP
# so that privatelink DNS zones (linked only to hub) resolve
# correctly from any peered VNet.
# -------------------------------------------------------

resource "azurerm_private_dns_resolver" "this" {
  count               = var.enable_dns_resolver ? 1 : 0
  name                = "dns-resolver-${var.product-name}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_id  = azurerm_virtual_network.hub.id
  tags                = var.tags
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "this" {
  count                   = var.enable_dns_resolver ? 1 : 0
  name                    = "dns-resolver-inbound-${var.product-name}"
  private_dns_resolver_id = azurerm_private_dns_resolver.this[0].id
  location                = azurerm_resource_group.hub.location
  tags                    = var.tags

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.dns_inbound[0].id
  }
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "this" {
  count                   = var.enable_dns_resolver ? 1 : 0
  name                    = "dns-resolver-outbound-${var.product-name}"
  private_dns_resolver_id = azurerm_private_dns_resolver.this[0].id
  location                = azurerm_resource_group.hub.location
  subnet_id               = azurerm_subnet.dns_outbound[0].id
  tags                    = var.tags
}
