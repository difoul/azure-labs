
# resource "azurerm_service_plan" "webapp-asp" {
#   location            = azurerm_resource_group.web-app-rg.location
#   name                = "webapp-aps-${var.product-name}"
#   os_type             = "Linux"
#   resource_group_name = azurerm_resource_group.web-app-rg.name
#   sku_name            = "B1"
# }

# resource "azurerm_linux_web_app" "lin-webapp-prv" {
#   location                      = azurerm_resource_group.web-app-rg.location
#   name                          = "lin-webapp-${var.product-name}"
#   resource_group_name           = azurerm_resource_group.web-app-rg.name
#   service_plan_id               = azurerm_service_plan.webapp-asp.id
#   depends_on                    = [azurerm_service_plan.webapp-asp]
#   public_network_access_enabled = true
#   virtual_network_subnet_id     = azurerm_subnet.webapp_subnet-spoke-01.id
#   https_only                    = true
#   site_config {
#     minimum_tls_version = "1.2"
#     application_stack {
#       python_version = "3.12"
#     }
#   }
# }
#
# #  Deploy code from a public GitHub repo
# resource "azurerm_app_service_source_control" "fastapi-example" {
#   app_id             = azurerm_linux_web_app.lin-webapp-prv.id
#   repo_url           = "https://github.com/Azure-Samples/msdocs-python-fastapi-webapp-quickstart"
#   branch             = "main"
#   use_manual_integration = true
#   use_mercurial      = false
# }