data "azurerm_resource_group" "acr_resource_group" {
  name = "${var.name}-rg"
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.name}acr"
  resource_group_name = data.azurerm_resource_group.acr_resource_group.name
  location            = data.azurerm_resource_group.acr_resource_group.location
  sku                 = "Premium"
  admin_enabled       = false

  tags = {
    Environment = var.environment
  }
}