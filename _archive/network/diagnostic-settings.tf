resource "azurerm_monitor_diagnostic_setting" "fw-diag" {
  name                           = "firewall-diagnostics"
  target_resource_id             = azurerm_firewall.firewall.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.law.id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.fw-diag-categories.metrics
    content {
      category = enabled_metric.value
    }
  }

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.fw-diag-categories.log_category_types
    content {
      category = enabled_log.value
    }
  }

}

data "azurerm_monitor_diagnostic_categories" "fw-diag-categories" {
  resource_id = azurerm_firewall.firewall.id
}



resource "azurerm_monitor_diagnostic_setting" "lb-diag" {
  name                           = "lb-diagnostics"
  target_resource_id             = azurerm_lb.vm02-lb.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.law.id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.lb-diag-categories.metrics
    content {
      category = enabled_metric.value
    }
  }

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.lb-diag-categories.log_category_types
    content {
      category = enabled_log.value
    }
  }

}

data "azurerm_monitor_diagnostic_categories" "lb-diag-categories" {
  resource_id = azurerm_lb.vm02-lb.id
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
