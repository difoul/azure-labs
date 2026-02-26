output "container_app_id" {
  description = "Resource ID of the Container App."
  value       = azurerm_container_app.this.id
}

output "container_app_fqdn" {
  description = "Fully qualified domain name (FQDN) of the Container App ingress."
  value       = azurerm_container_app.this.ingress[0].fqdn
}

output "container_app_environment_id" {
  description = "Resource ID of the Container App Environment."
  value       = azurerm_container_app_environment.this.id
}
