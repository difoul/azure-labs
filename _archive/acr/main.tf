resource "azurerm_container_registry" "shared" {
  name                = "acrprodsharedfbe"
  resource_group_name = azurerm_resource_group.acr.name
  location            = azurerm_resource_group.acr.location
  sku                 = "Premium" # Required for private endpoints, geo-replication
  admin_enabled       = false     # Enforce Entra ID only

  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr.id]
  }

  # Encryption with CMK
  encryption {
    key_vault_key_id   = azurerm_key_vault_key.acr.id
    identity_client_id = azurerm_user_assigned_identity.acr.client_id
  }

  quarantine_policy_enabled = true
  zone_redundancy_enabled   = true

  depends_on = [time_sleep.wait_for_rbac_acr]
}

# Private Endpoint
resource "azurerm_private_endpoint" "acr" {
  name                = "pe-acr-shared"
  location            = azurerm_resource_group.acr.location
  resource_group_name = azurerm_resource_group.acr.name
  subnet_id           = azurerm_subnet.endpoints.id

  private_service_connection {
    name                           = "acr-privatelink"
    private_connection_resource_id = azurerm_container_registry.shared.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr.id]
  }
}

# # Entra ID RBAC Assignments
# resource "azurerm_role_assignment" "acrpull_aks" {
#   scope                = azurerm_container_registry.shared.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_kubernetes_cluster.prod.kubelet_identity[0].object_id
# }

# resource "azurerm_role_assignment" "acrpush_cicd" {
#   scope                = azurerm_container_registry.shared.id
#   role_definition_name = "AcrPush"
#   principal_id         = data.azuread_service_principal.cicd.object_id
# }

# # Diagnostic Settings
# resource "azurerm_monitor_diagnostic_setting" "acr" {
#   name                       = "acr-diagnostics"
#   target_resource_id         = azurerm_container_registry.shared.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.prod.id

#   enabled_log {
#     category = "ContainerRegistryRepositoryEvents"
#   }
#   enabled_log {
#     category = "ContainerRegistryLoginEvents"
#   }

#   metric {
#     category = "AllMetrics"
#   }
# }

# # Azure Policy - Allowed Locations for ACR replication
# resource "azurerm_resource_group_policy_assignment" "acr_allowed_locations" {
#   name                 = "acr-geo-restrictions"
#   resource_group_id    = azurerm_resource_group.acr.id
#   policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988"

#   parameters = jsonencode({
#     listOfAllowedLocations = {
#       value = ["eastus2", "westus2"] # Your regions
#     }
#   })
# }