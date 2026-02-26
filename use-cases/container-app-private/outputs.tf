output "acr_login_server" {
  description = "ACR login server — use this as your docker push / docker pull target."
  value       = module.acr.acr_login_server
}

output "acr_name" {
  description = "Name of the Azure Container Registry."
  value       = module.acr.acr_name
}

output "container_app_fqdn" {
  description = "FQDN of the Container App ingress endpoint."
  value       = module.container_app.container_app_fqdn
}

output "management_vm_password" {
  description = "Auto-generated admin password for the management VM."
  value       = module.management_vm.vm_password
  sensitive   = true
}

output "pull_identity_principal_id" {
  description = "Principal ID of the AcrPull managed identity. Reference this when adding further ABAC repository assignments."
  value       = azurerm_user_assigned_identity.aca_pull.principal_id
}
