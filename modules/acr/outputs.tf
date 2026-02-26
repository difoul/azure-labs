output "acr_id" {
  description = "Resource ID of the Azure Container Registry."
  value       = azurerm_container_registry.this.id
}

output "acr_login_server" {
  description = "Login server URL of the Azure Container Registry."
  value       = azurerm_container_registry.this.login_server
}

output "acr_name" {
  description = "Name of the Azure Container Registry."
  value       = azurerm_container_registry.this.name
}

output "acr_identity_principal_id" {
  description = "Principal ID of the ACR user-assigned managed identity."
  value       = azurerm_user_assigned_identity.acr.principal_id
}
