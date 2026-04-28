output "kubelet_object_id" {
  value = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "resource_group_name" {
  value = azurerm_kubernetes_cluster.k8s.resource_group_name
}
