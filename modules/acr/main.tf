# -------------------------------------------------------
# Resource Group
# -------------------------------------------------------

resource "azurerm_resource_group" "acr" {
  location = var.location
  name     = "rg-acr-${var.product-name}"
  tags     = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

# -------------------------------------------------------
# User-assigned Managed Identity (for CMK encryption)
# -------------------------------------------------------

resource "azurerm_user_assigned_identity" "acr" {
  location            = azurerm_resource_group.acr.location
  name                = "id-acr-${var.product-name}"
  resource_group_name = azurerm_resource_group.acr.name
}

# Grant the ACR identity Crypto User on the externally-managed Key Vault
resource "azurerm_role_assignment" "acr_crypto_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.acr.principal_id
}

resource "time_sleep" "wait_for_rbac_acr" {
  depends_on      = [azurerm_role_assignment.acr_crypto_user]
  create_duration = "60s"
}

# -------------------------------------------------------
# Azure Container Registry
# -------------------------------------------------------

resource "azurerm_container_registry" "this" {
  name                = "acr${var.product-name}"
  resource_group_name = azurerm_resource_group.acr.name
  location            = azurerm_resource_group.acr.location
  sku                 = "Premium"
  admin_enabled       = false

  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr.id]
  }

  encryption {
    key_vault_key_id   = var.key_vault_key_id
    identity_client_id = azurerm_user_assigned_identity.acr.client_id
  }

  quarantine_policy_enabled = false
  zone_redundancy_enabled   = true

  dynamic "georeplications" {
    for_each = var.geo_replication_locations
    content {
      location                  = georeplications.value.location
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
    }
  }

  depends_on = [time_sleep.wait_for_rbac_acr]

  lifecycle {
    prevent_destroy = true
  }
}

# -------------------------------------------------------
# ABAC — repository-level permissions (azurerm 4.x does not expose roleAssignmentMode)
# Uses azapi_update_resource to patch the property in-place after ACR creation
# API ref: Microsoft.ContainerRegistry/registries@2025-11-01
# -------------------------------------------------------

resource "azapi_update_resource" "acr_abac" {
  count       = var.enable_abac ? 1 : 0
  type        = "Microsoft.ContainerRegistry/registries@2025-11-01"
  resource_id = azurerm_container_registry.this.id

  body = {
    properties = {
      roleAssignmentMode = "AbacRepositoryPermissions"
    }
  }

  depends_on = [azurerm_container_registry.this]
}

# ACR private endpoint
resource "azurerm_private_endpoint" "acr" {
  name                = "pe-acr-${var.product-name}"
  location            = azurerm_resource_group.acr.location
  resource_group_name = azurerm_resource_group.acr.name
  subnet_id           = var.endpoint_subnet_id

  private_service_connection {
    name                           = "acr-privatelink"
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr.id]
  }
}
