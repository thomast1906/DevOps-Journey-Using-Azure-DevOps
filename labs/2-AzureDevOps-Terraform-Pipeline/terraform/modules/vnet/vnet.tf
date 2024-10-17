data "azurerm_resource_group" "vnet_resource_group" {
  name = "${var.name}-rg"
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.name}-vnet"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.vnet_resource_group.name
  address_space       = [var.network_address_space]

  tags = {
    Environment = var.environment
  }

}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_address_name
  resource_group_name  = data.azurerm_resource_group.vnet_resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.aks_subnet_address_prefix]
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = var.appgw_subnet_address_name
  resource_group_name  = data.azurerm_resource_group.vnet_resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.appgw_subnet_address_prefix]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.ServiceNetworking/trafficControllers"
    }
  }
}