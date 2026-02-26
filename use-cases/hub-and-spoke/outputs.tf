output "hub_vnet_id" {
  description = "Resource ID of the hub VNet."
  value       = module.hub.hub_vnet_id
}

output "firewall_private_ip" {
  description = "Private IP of the Azure Firewall."
  value       = module.hub.firewall_private_ip
}

output "spoke_01_vnet_id" {
  description = "Resource ID of spoke-01 VNet."
  value       = module.spoke_01.spoke_vnet_id
}

output "spoke_02_vnet_id" {
  description = "Resource ID of spoke-02 VNet."
  value       = module.spoke_02.spoke_vnet_id
}

output "spoke_03_vnet_id" {
  description = "Resource ID of spoke-03 VNet."
  value       = module.spoke_03.spoke_vnet_id
}

output "compute_spk01_vm_ips" {
  description = "Private IP addresses of spoke-01 VMs."
  value       = module.compute_spk01.vm_private_ips
}

output "compute_spk01_vm_password" {
  description = "Admin password for spoke-01 VMs."
  value       = module.compute_spk01.vm_password
  sensitive   = true
}

output "compute_spk02_lb_private_ip" {
  description = "Frontend private IP of the spoke-02 load balancer."
  value       = module.compute_spk02.lb_private_ip
}

output "compute_spk02_vm_password" {
  description = "Admin password for spoke-02 VMs."
  value       = module.compute_spk02.vm_password
  sensitive   = true
}
