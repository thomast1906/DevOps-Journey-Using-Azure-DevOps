 data "azurerm_resource_group" "kubernetes_resource_group" {
  name     = "${var.name}-rg"
 }

 data "azurerm_log_analytics_workspace" "workspace" {
  name                = "${var.name}la"
  resource_group_name = data.azurerm_resource_group.kubernetes_resource_group.name
 }

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.kubernetes_resource_group.name
  dns_prefix          = var.name
  kubernetes_version  = var.kubernetes_version
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  node_resource_group = "${var.name}-node-rg"

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  default_node_pool {
    name                 = "agentpool"
    node_count           = var.agent_count
    vm_size              = var.vm_size
    vnet_subnet_id       = var.aks_subnet
    type                 = "VirtualMachineScaleSets"
    orchestrator_version = var.kubernetes_version
      os_sku = "AzureLinux"
  }

  identity {
    type = "SystemAssigned"
  }

 oms_agent {
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.workspace.id
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = false
    managed                = true
    admin_group_object_ids = [var.aks_admins_group_object_id]
  }

  tags = {
    Environment = var.environment
  }
}

data "azurerm_resource_group" "node_resource_group" {
  name = azurerm_kubernetes_cluster.k8s.node_resource_group
         depends_on = [
     azurerm_kubernetes_cluster.k8s
  ]
}
