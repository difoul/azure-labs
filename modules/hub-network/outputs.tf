output "hub_vnet_id" {
  description = "Resource ID of the hub VNet."
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Name of the hub VNet."
  value       = azurerm_virtual_network.hub.name
}

output "hub_resource_group_name" {
  description = "Name of the hub VNet resource group."
  value       = azurerm_resource_group.hub.name
}

output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall."
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "firewall_id" {
  description = "Resource ID of the Azure Firewall."
  value       = azurerm_firewall.this.id
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "network_watcher_name" {
  description = "Name of the Network Watcher."
  value       = azurerm_network_watcher.this.name
}

output "endpoint_subnet_id" {
  description = "Resource ID of the private endpoints subnet in the hub VNet."
  value       = azurerm_subnet.endpoints.id
}

output "inbound_dns_subnet_id" {
  description = "Resource ID of the DNS resolver inbound subnet. Null when neither enable_dns_resolver_subnets nor enable_dns_resolver is true."
  value       = local.create_dns_subnets ? azurerm_subnet.dns_inbound[0].id : null
}

output "outbound_dns_subnet_id" {
  description = "Resource ID of the DNS resolver outbound subnet. Null when neither enable_dns_resolver_subnets nor enable_dns_resolver is true."
  value       = local.create_dns_subnets ? azurerm_subnet.dns_outbound[0].id : null
}

output "dns_resolver_inbound_ip" {
  description = "Private IP of the DNS Resolver inbound endpoint. Pass as custom_dns_servers to spoke-network modules so they resolve hub-linked private DNS zones. Null when enable_dns_resolver = false."
  value       = var.enable_dns_resolver ? azurerm_private_dns_resolver_inbound_endpoint.this[0].ip_configurations[0].private_ip_address : null
}

