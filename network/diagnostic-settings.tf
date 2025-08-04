resource "azurerm_monitor_diagnostic_setting" "fw-diag" {
  name                       = "firewall-diagnostics"
  target_resource_id         = azurerm_firewall.firewall.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

}


# resource "azurerm_monitor_diagnostic_setting" "web-app-diag" {
#   name                       = "webapp-diagnostics"
#   target_resource_id         = azurerm_linux_web_app.lin-webapp-prv.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
#
#   enabled_log {
#     category = "AppServiceHTTPLogs"
#   }
#
#   enabled_log {
#     category = "AppServiceAppLogs"
#   }
#
#   enabled_log {
#     category = "AppServiceAuditLogs"
#   }
#
# }
