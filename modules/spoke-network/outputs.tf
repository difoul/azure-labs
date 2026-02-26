output "spoke_vnet_id" {
  description = "Resource ID of the spoke VNet."
  value       = azurerm_virtual_network.spoke.id
}

output "spoke_vnet_name" {
  description = "Name of the spoke VNet."
  value       = azurerm_virtual_network.spoke.name
}

output "spoke_resource_group_name" {
  description = "Name of the spoke resource group."
  value       = azurerm_resource_group.spoke.name
}

output "subnet_ids" {
  description = "Map of subnet name to subnet resource ID."
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "nsg_id" {
  description = "Resource ID of the spoke Network Security Group."
  value       = azurerm_network_security_group.spoke.id
}
