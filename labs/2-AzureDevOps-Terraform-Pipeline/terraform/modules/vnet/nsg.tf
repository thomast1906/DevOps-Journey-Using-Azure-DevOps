resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.vnet_resource_group.name
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_subnet_network_security_group_association" "aks_subnet" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "app_gwsubnet" {
  subnet_id                 = azurerm_subnet.appgw_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}