resource "azurerm_resource_group" "webapp_resource_group" {
  name     = "rg-home-iotluk-webapp"
  location = var.location_name
}

# resource "azurerm_service_plan" "webapp_appservice" {
#   name                = "home-iotluk-web-appserviceplan"
#   location            = azurerm_resource_group.webapp_resource_group.location
#   resource_group_name = azurerm_resource_group.webapp_resource_group.name
#   os_type             = "Linux"
#   sku_name            = "FREE"

# }

# resource "azurerm_linux_web_app" "webapp" {
#   name                = "home-iotluk-webapp"
#   location            = azurerm_resource_group.webapp_resource_group.location
#   resource_group_name = azurerm_resource_group.webapp_resource_group.name
#   service_plan_id     = azurerm_service_plan.webapp_appservice.id

#   site_config {
#     always_on = false
#   }

# }
# TODO: something wrong with those , make up goes well
