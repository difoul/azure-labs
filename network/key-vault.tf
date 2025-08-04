# resource "azurerm_key_vault" "key-vault" {
#   name                          = "kv-${random_integer.ri.result}-${var.product-name}"
#   location                      = azurerm_resource_group.keyvault-rg.location
#   resource_group_name           = azurerm_resource_group.keyvault-rg.name
#   sku_name                      = "standard"
#   tenant_id                     = data.azurerm_client_config.current.tenant_id
#   enable_rbac_authorization     = true
#   purge_protection_enabled      = false
#   soft_delete_retention_days    = 7
#   public_network_access_enabled = false
#
#   tags = var.tags
#
# }