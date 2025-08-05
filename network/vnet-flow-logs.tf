resource "azurerm_storage_account" "nw-storage-account" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.network-watcher-rg.location
  name                     = "nwsto${random_integer.ri.result}${var.product-name}"
  resource_group_name      = azurerm_resource_group.network-watcher-rg.name
}

resource "azurerm_network_watcher_flow_log" "vnet-flow-log-spoke-01" {
  enabled              = true
  name                 = "vnet-flow-log-spoke-01"
  network_watcher_name = azurerm_network_watcher.network-watcher.name
  resource_group_name  = azurerm_resource_group.network-watcher-rg.name
  storage_account_id   = azurerm_storage_account.nw-storage-account.id
  target_resource_id   = azurerm_virtual_network.spoke-01.id


  retention_policy {
    days    = 0
    enabled = false
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.law.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.law.location
    workspace_resource_id = azurerm_log_analytics_workspace.law.id
    interval_in_minutes   = 10
  }
}