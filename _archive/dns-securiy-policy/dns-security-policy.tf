resource "azapi_resource" "private_zones_list" {
  type      = "Microsoft.Network/dnsResolverDomainLists@2025-05-01"
  name      = "private_zones_list"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  tags      = var.tags
  body = {
    properties = {
      domains = [
        "difoul.io."
      ]
    }
  }
}


resource "azapi_resource" "all_domains" {
  type      = "Microsoft.Network/dnsResolverDomainLists@2025-05-01"
  name      = "all_domains"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  tags      = var.tags
  body = {
    properties = {
      domains = [
        "."
      ]
    }
  }
}


resource "azapi_resource" "dns_sec_policy" {
  type      = "Microsoft.Network/dnsResolverPolicies@2025-05-01"
  name      = "dns-sec-policy"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  tags      = var.tags
  body = {
    properties = {
    }
  }
}


resource "azapi_resource" "dns_sec_policy_vnet_link" {
  type      = "Microsoft.Network/dnsResolverPolicies/virtualNetworkLinks@2025-05-01"
  name      = "dns_sec_policy_vnet_link"
  parent_id = azapi_resource.dns_sec_policy.id
  location  = azurerm_resource_group.rg.location
  tags      = var.tags
  body = {
    properties = {
      virtualNetwork = {
        id = azurerm_virtual_network.hub.id
      }
    }
  }
}


resource "azapi_resource" "all_domains_rule" {
  type      = "Microsoft.Network/dnsResolverPolicies/dnsSecurityRules@2025-05-01"
  name      = "all_domains_rule"
  parent_id = azapi_resource.dns_sec_policy.id
  location  = azurerm_resource_group.rg.location
  tags      = var.tags
  body = {
    properties = {
      action = {
        actionType = "Block"
      }
      dnsResolverDomainLists = [
        {
          id = azapi_resource.all_domains.id
        }
      ]
      dnsSecurityRuleState = "Enabled"
      priority             = 65000
    }
  }
}


resource "azapi_resource" "private_zones_rule" {
  type      = "Microsoft.Network/dnsResolverPolicies/dnsSecurityRules@2025-05-01"
  name      = "private_zones_rule"
  parent_id = azapi_resource.dns_sec_policy.id
  location  = azurerm_resource_group.rg.location
  tags      = var.tags
  body = {
    properties = {
      action = {
        actionType = "Allow"
      }
      dnsResolverDomainLists = [
        {
          id = azapi_resource.private_zones_list.id
        }
      ]
      dnsSecurityRuleState = "Enabled"
      priority             = 1000
    }
  }
}


resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.product-name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "diag-base" {
  depends_on = [
    azapi_resource.dns_sec_policy
  ]

  name                       = "diag-base"
  target_resource_id         = azapi_resource.dns_sec_policy.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "DnsResponse"
  }
}