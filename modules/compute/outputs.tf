output "vm_private_ips" {
  description = "List of private IP addresses for all deployed VMs."
  value       = [for nic in azurerm_network_interface.vm : nic.private_ip_address]
}

output "vm_password" {
  description = "Generated admin password for the VMs."
  value       = random_password.vm.result
  sensitive   = true
}

output "lb_private_ip" {
  description = "Frontend private IP of the internal load balancer. Null when enable_load_balancer = false."
  value       = var.enable_load_balancer ? azurerm_lb.this[0].frontend_ip_configuration[0].private_ip_address : null
}
