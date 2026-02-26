output "hub_vnet_id" {
  description = "Resource ID of the hub VNet."
  value       = module.hub.hub_vnet_id
}

output "dns_resolver_inbound_ip" {
  description = "Private IP of the DNS resolver inbound endpoint (configure as DNS server on VMs/VNets)."
  value       = module.dns_security.dns_resolver_inbound_ip
}

output "dns_security_policy_id" {
  description = "Resource ID of the DNS Security Policy."
  value       = module.dns_security.dns_security_policy_id
}
