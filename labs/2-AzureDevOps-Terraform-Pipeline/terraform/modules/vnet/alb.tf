# Azure Application Load Balancer for Containers
resource "azurerm_application_load_balancer" "alb" {
  name                = "${var.name}-alb"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.vnet_resource_group.name

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_application_load_balancer_subnet_association" "alb" {
  name                         = "alb-subnet-association"
  application_load_balancer_id = azurerm_application_load_balancer.alb.id
  subnet_id                    = azurerm_subnet.appgw_subnet.id
}

resource "azurerm_application_load_balancer_frontend" "alb" {
  name                         = "alb-frontend"
  application_load_balancer_id = azurerm_application_load_balancer.alb.id
}