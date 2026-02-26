output "dns_resolver_id" {
  description = "Resource ID of the Private DNS Resolver."
  value       = azurerm_private_dns_resolver.this.id
}

output "dns_resolver_inbound_ip" {
  description = "Private IP address of the DNS resolver inbound endpoint."
  value       = azurerm_private_dns_resolver_inbound_endpoint.this.ip_configurations[0].private_ip_address
}

output "dns_security_policy_id" {
  description = "Resource ID of the DNS Security Policy."
  value       = azapi_resource.dns_security_policy.id
}
