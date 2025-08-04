
# resource "azurerm_private_dns_zone" "dnsprivatezone" {
#   name                = "privatelink.azurewebsites.net"
#   resource_group_name = azurerm_resource_group.web-app-rg.name
# }
#
# resource "azurerm_private_dns_zone_virtual_network_link" "dnszonelink" {
#   name = "dnszonelink"
#   resource_group_name = azurerm_resource_group.hub-rg
#   private_dns_zone_name = azurerm_private_dns_zone.dnsprivatezone.name
#   virtual_network_id = azurerm_virtual_network.hub.id
# }


# resource "azurerm_private_endpoint" "web-app-pe" {
#   name                = "my-python-app"
#   location            = azurerm_resource_group.web-app-rg.location
#   resource_group_name = azurerm_resource_group.web-app-rg.name
#   subnet_id           = azurerm_subnet.endpoint-spoke-01.id
#   #
#   # private_dns_zone_group {
#   #   name = "privatednszonegroup"
#   #   private_dns_zone_ids = [azurerm_private_dns_zone.dnsprivatezone.id]
#   # }
#
#   private_service_connection {
#     name = "privateendpointconnection"
#     private_connection_resource_id = azurerm_linux_web_app.lin-webapp-prv.id
#     subresource_names = ["sites"]
#     is_manual_connection = false
#   }
# }

