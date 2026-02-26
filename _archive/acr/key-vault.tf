resource "azurerm_key_vault" "acr" {
  name                = "kv-acr-${var.product-name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.acr.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  rbac_authorization_enabled = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules = ["xxx.xxx.xxx.xxx/32"]
  }

  tags = var.tags
}

# RBAC assignments
resource "azurerm_role_assignment" "kv" {
  scope                = azurerm_key_vault.acr.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
  depends_on           = [azurerm_private_endpoint.pe_kv]
}

resource "time_sleep" "wait_for_rbac" {
  depends_on      = [azurerm_role_assignment.kv]
  create_duration = "60s"
}

resource "azurerm_private_endpoint" "pe_kv" {
  name                = "pe-kv"
  location            = azurerm_resource_group.acr.location
  resource_group_name = azurerm_resource_group.acr.name
  subnet_id           = azurerm_subnet.endpoints.id

  private_service_connection {
    name                           = "kvacr-privatelink"
    private_connection_resource_id = azurerm_key_vault.acr.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
  }
}

# CMK for ACR encryption
resource "azurerm_key_vault_key" "acr" {
  name         = "cmk-acr-encryption"
  key_vault_id = azurerm_key_vault.acr.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }

  depends_on = [time_sleep.wait_for_rbac]
}