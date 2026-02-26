output "hub_vnet_id" {
  description = "Resource ID of the hub VNet."
  value       = module.hub.hub_vnet_id
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = module.key_vault.key_vault_id
}

output "key_vault_uri" {
  description = "URI of the Key Vault."
  value       = module.key_vault.key_vault_uri
}

output "acr_login_server" {
  description = "ACR login server URL."
  value       = module.acr.acr_login_server
}

output "acr_name" {
  description = "Name of the Azure Container Registry."
  value       = module.acr.acr_name
}
