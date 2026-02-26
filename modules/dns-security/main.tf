# -------------------------------------------------------
# Resource Group
# -------------------------------------------------------

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "rg-dns-security-${var.product-name}"
  tags     = var.tags
}

# -------------------------------------------------------
# Private DNS Zones + VNet Links
# -------------------------------------------------------

resource "azurerm_private_dns_zone" "allowed" {
  for_each            = toset(var.allowed_private_zones)
  name                = each.value
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "allowed_to_hub" {
  for_each              = toset(var.allowed_private_zones)
  name                  = "${replace(each.value, ".", "-")}-to-hub"
  private_dns_zone_name = azurerm_private_dns_zone.allowed[each.value].name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = var.hub_vnet_id
}

# -------------------------------------------------------
# DNS Resolver (inbound + outbound endpoints)
# -------------------------------------------------------

resource "azurerm_private_dns_resolver" "this" {
  name                = "dns-resolver-${var.product-name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  virtual_network_id  = var.hub_vnet_id
  tags                = var.tags
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "this" {
  name                    = "dns-resolver-inbound-${var.product-name}"
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  location                = azurerm_private_dns_resolver.this.location

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = var.inbound_subnet_id
  }

  tags = var.tags
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "this" {
  name                    = "dns-resolver-outbound-${var.product-name}"
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  location                = azurerm_private_dns_resolver.this.location
  subnet_id               = var.outbound_subnet_id
  tags                    = var.tags
}

# -------------------------------------------------------
# DNS Security Policy (via azapi — not yet in azurerm)
# -------------------------------------------------------

resource "azapi_resource" "allowed_domains_list" {
  type      = "Microsoft.Network/dnsResolverDomainLists@2025-05-01"
  name      = "allowed-domains-${var.product-name}"
  parent_id = azurerm_resource_group.this.id
  location  = azurerm_resource_group.this.location
  tags      = var.tags
  body = {
    properties = {
      domains = var.allowed_domains
    }
  }
}

resource "azapi_resource" "all_domains_list" {
  type      = "Microsoft.Network/dnsResolverDomainLists@2025-05-01"
  name      = "all-domains-${var.product-name}"
  parent_id = azurerm_resource_group.this.id
  location  = azurerm_resource_group.this.location
  tags      = var.tags
  body = {
    properties = {
      domains = ["."]
    }
  }
}

resource "azapi_resource" "dns_security_policy" {
  type      = "Microsoft.Network/dnsResolverPolicies@2025-05-01"
  name      = "dns-security-policy-${var.product-name}"
  parent_id = azurerm_resource_group.this.id
  location  = azurerm_resource_group.this.location
  tags      = var.tags
  body = {
    properties = {}
  }
}

resource "azapi_resource" "policy_vnet_link" {
  type      = "Microsoft.Network/dnsResolverPolicies/virtualNetworkLinks@2025-05-01"
  name      = "policy-vnet-link-${var.product-name}"
  parent_id = azapi_resource.dns_security_policy.id
  location  = azurerm_resource_group.this.location
  tags      = var.tags
  body = {
    properties = {
      virtualNetwork = {
        id = var.hub_vnet_id
      }
    }
  }
}

resource "azapi_resource" "allow_rule" {
  type      = "Microsoft.Network/dnsResolverPolicies/dnsSecurityRules@2025-05-01"
  name      = "allow-private-zones-${var.product-name}"
  parent_id = azapi_resource.dns_security_policy.id
  location  = azurerm_resource_group.this.location
  tags      = var.tags
  body = {
    properties = {
      action = {
        actionType = "Allow"
      }
      dnsResolverDomainLists = [
        { id = azapi_resource.allowed_domains_list.id }
      ]
      dnsSecurityRuleState = "Enabled"
      priority             = 1000
    }
  }
}

resource "azapi_resource" "block_rule" {
  type      = "Microsoft.Network/dnsResolverPolicies/dnsSecurityRules@2025-05-01"
  name      = "block-all-${var.product-name}"
  parent_id = azapi_resource.dns_security_policy.id
  location  = azurerm_resource_group.this.location
  tags      = var.tags
  body = {
    properties = {
      action = {
        actionType = "Block"
      }
      dnsResolverDomainLists = [
        { id = azapi_resource.all_domains_list.id }
      ]
      dnsSecurityRuleState = "Enabled"
      priority             = 65000
    }
  }
}

# -------------------------------------------------------
# Log Analytics + Diagnostics for DNS Security Policy
# -------------------------------------------------------

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-dns-${var.product-name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "dns_policy" {
  depends_on = [azapi_resource.dns_security_policy]

  name                       = "dns-policy-diagnostics"
  target_resource_id         = azapi_resource.dns_security_policy.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "DnsResponse"
  }
}
