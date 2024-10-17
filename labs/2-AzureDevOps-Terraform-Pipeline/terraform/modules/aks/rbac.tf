resource "azurerm_role_assignment" "node_infrastructure_update_scale_set" {
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

data "azurerm_container_registry" "acr" {
  name                = "${var.name}acr"
  resource_group_name = data.azurerm_resource_group.kubernetes_resource_group.name
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "acrpull"
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

resource "azurerm_role_assignment" "appgwcontainerfix" {
  principal_id         = azurerm_user_assigned_identity.alb_identity.principal_id
  scope                = data.azurerm_resource_group.kubernetes_resource_group.id
  role_definition_name = "AppGw for Containers Configuration Manager"
  depends_on = [
    azurerm_kubernetes_cluster.k8s,
    azurerm_user_assigned_identity.alb_identity
  ]
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-vnet"
  resource_group_name = data.azurerm_resource_group.kubernetes_resource_group.name
}

data "azurerm_subnet" "appgwsubnet" {
  name                 = "appgw"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.kubernetes_resource_group.name
}

# Delegate Network Contributor permission for join to association subnet
# az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $ALB_SUBNET_ID --role "4d97b98b-1d4f-4787-a291-c67834d212e7" 
resource "azurerm_role_assignment" "appgwcontainerfix2" {
  principal_id         = azurerm_user_assigned_identity.alb_identity.principal_id
  scope                = data.azurerm_subnet.appgwsubnet.id
  role_definition_name = "Network Contributor"
  depends_on = [
    azurerm_kubernetes_cluster.k8s,
    azurerm_user_assigned_identity.alb_identity
  ]
}