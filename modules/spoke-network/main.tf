# -------------------------------------------------------
# Resource Group
# -------------------------------------------------------

resource "azurerm_resource_group" "spoke" {
  location = var.location
  name     = "${var.spoke_name}-vnet-${var.product-name}-rg"
  tags     = var.tags
}

# -------------------------------------------------------
# Spoke VNet + Subnets
# -------------------------------------------------------

resource "azurerm_virtual_network" "spoke" {
  name                = "${var.spoke_name}-${var.product-name}"
  address_space       = [var.spoke_address_space]
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  dns_servers         = length(var.custom_dns_servers) > 0 ? var.custom_dns_servers : null
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [each.value.cidr]

  private_endpoint_network_policies = each.value.private_endpoint_network_policies_enabled ? "Enabled" : "Disabled"

  dynamic "delegation" {
    for_each = each.value.delegation_name != null ? [1] : []
    content {
      name = each.value.delegation_name
      service_delegation {
        name    = each.value.service_delegation_name
        actions = each.value.service_delegation_actions
      }
    }
  }
}

# -------------------------------------------------------
# Network Security Group + Rules
# -------------------------------------------------------

resource "azurerm_network_security_group" "spoke" {
  name                = "${var.spoke_name}-nsg-${var.product-name}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "admin_allow" {
  count                       = var.admin_ip != "" ? 1 : 0
  name                        = "allow-all-from-admin-ip"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.admin_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.spoke.name
  network_security_group_name = azurerm_network_security_group.spoke.name
}

resource "azurerm_network_security_rule" "custom" {
  for_each = { for r in var.nsg_rules : r.name => r }

  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = each.value.source_port_range
  destination_port_range       = each.value.destination_port_range
  source_address_prefix        = each.value.source_address_prefixes != null ? null : coalesce(each.value.source_address_prefix, "*")
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefixes != null ? null : coalesce(each.value.destination_address_prefix, "*")
  destination_address_prefixes = each.value.destination_address_prefixes
  resource_group_name          = azurerm_resource_group.spoke.name
  network_security_group_name  = azurerm_network_security_group.spoke.name
}

# Associate NSG with all non-delegated subnets
resource "azurerm_subnet_network_security_group_association" "spoke" {
  for_each = { for k, v in var.subnets : k => v if v.delegation_name == null }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.spoke.id
}

# -------------------------------------------------------
# Route Table — send all traffic through the firewall
# -------------------------------------------------------

resource "azurerm_route_table" "to_firewall" {
  location                      = azurerm_resource_group.spoke.location
  name                          = "${var.spoke_name}-to-fw-rt-${var.product-name}"
  resource_group_name           = azurerm_resource_group.spoke.name
  bgp_route_propagation_enabled = false
  tags                          = var.tags

  route {
    name                   = "to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "spoke" {
  for_each = var.subnets

  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = azurerm_route_table.to_firewall.id
}

# -------------------------------------------------------
# VNet Peering (bidirectional)
# -------------------------------------------------------

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-${var.spoke_name}"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "${var.spoke_name}-to-hub"
  resource_group_name       = azurerm_resource_group.spoke.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = var.hub_vnet_id
  allow_forwarded_traffic   = true
}
