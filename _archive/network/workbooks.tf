# resource "random_uuid" "firewall-workbook-uuid" {
# }
#
# resource "azurerm_application_insights_workbook" "firewall-workbook" {
#   data_json           = jsonencode(templatefile("./workbooks/AzureFirewallWorkbookTemplate.json", { workbookSourceId = azurerm_log_analytics_workspace.law.id }))
#   display_name        = "Azure Firewall Workbook"
#   location            = azurerm_resource_group.hub-rg.location
#   name                = random_uuid.firewall-workbook-uuid.result
#   resource_group_name = azurerm_resource_group.hub-rg.name
#   source_id           = lower(azurerm_log_analytics_workspace.law.id)
#
#   tags = var.tags
# }