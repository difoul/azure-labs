output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "key_vault_key_id" {
  description = "Resource ID of the CMK key (versionless). Pass to ACR or other modules for encryption."
  value       = azurerm_key_vault_key.this.versionless_id
}

output "key_vault_key_name" {
  description = "Name of the CMK key."
  value       = azurerm_key_vault_key.this.name
}

output "resource_group_name" {
  description = "Name of the Key Vault resource group."
  value       = azurerm_resource_group.kv.name
}
