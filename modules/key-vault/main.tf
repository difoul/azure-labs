# -------------------------------------------------------
# Resource Group
# -------------------------------------------------------

resource "azurerm_resource_group" "kv" {
  location = var.location
  name     = "rg-kv-${var.product-name}"
  tags     = var.tags
}

data "azurerm_client_config" "current" {}

# -------------------------------------------------------
# Key Vault
# -------------------------------------------------------

resource "azurerm_key_vault" "this" {
  name                = coalesce(var.kv_name_override, "kv-${var.product-name}")
  location            = azurerm_resource_group.kv.location
  resource_group_name = azurerm_resource_group.kv.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  rbac_authorization_enabled = true
  public_network_access_enabled  = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = var.deployer_ip_rules
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

# RBAC: grant the deploying principal KV Administrator so it can create keys
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
  depends_on           = [azurerm_private_endpoint.kv]
}

resource "time_sleep" "wait_for_rbac" {
  depends_on      = [azurerm_role_assignment.kv_admin]
  create_duration = "60s"
}

# -------------------------------------------------------
# Private Endpoint + DNS Zone
# -------------------------------------------------------

resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.kv.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_to_hub" {
  name                  = "kv-to-hub"
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  resource_group_name   = azurerm_resource_group.kv.name
  virtual_network_id    = var.hub_vnet_id
}

resource "azurerm_private_endpoint" "kv" {
  name                = "pe-kv-${var.product-name}"
  location            = azurerm_resource_group.kv.location
  resource_group_name = azurerm_resource_group.kv.name
  subnet_id           = var.endpoint_subnet_id

  private_service_connection {
    name                           = "kv-privatelink"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "kv-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
  }
}

# -------------------------------------------------------
# CMK Key
# -------------------------------------------------------

resource "azurerm_key_vault_key" "this" {
  name         = var.key_name
  key_vault_id = azurerm_key_vault.this.id
  key_type     = var.key_type
  key_size     = var.key_size

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
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
