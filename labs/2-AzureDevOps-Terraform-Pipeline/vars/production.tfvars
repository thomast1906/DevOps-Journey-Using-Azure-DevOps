# General Variables
general_name = "devopsjourneyoct2024"
location     = "uksouth"

# Virtual Network
vnet_name                   = "devopsjourney-vnet"
network_address_space       = "192.168.0.0/16"
aks_subnet_address_prefix   = "192.168.0.0/24"
aks_subnet_address_name     = "aks"
appgw_subnet_address_prefix = "192.168.1.0/24"
appgw_subnet_address_name   = "appgw"

# AKS
aks_name           = "devopsjourneyaks"
kubernetes_version = "1.35"
vm_size            = "Standard_D2s_v3"
ssh_public_key     = "<replace-with-your-ssh-public-key>"


environment = "production"

admin_object_id = "278cc1b9-653d-464a-90f7-309e02d4b5d1"

# Object ID of the Azure AD group created in Lab 1 (AKS cluster admins group)
# Run: az ad group show --group "AKS-Cluster-Admins" --query id -o tsv
aks_admins_group_object_id = "REPLACE_WITH_AKS_ADMINS_GROUP_OBJECT_ID"