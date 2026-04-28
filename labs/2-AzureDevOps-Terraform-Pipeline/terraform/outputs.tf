output "aks_name" {
  description = "AKS cluster name"
  value       = module.aks.aks_name
}

output "aks_resource_group" {
  description = "Resource group containing the AKS cluster"
  value       = module.aks.resource_group_name
}
