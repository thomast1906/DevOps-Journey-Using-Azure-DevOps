# Add Application Insights to Terraform

Application Insights will be used to monitor the application once deployed!

1. Deploy Application Insights using:

`resource "azurerm_role_assignment" "aks-acr-rg" {
  scope                = module.acr.resource_group_id
  role_definition_name = "Acrpull"
  principal_id         = module.aks.kubelet_object_id

  depends_on = [
     module.aks,
     module.acr
  ]
}`


2. Update .yaml with your ACR image name

https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/4-Deploy-App-AKS/pipelines/scripts/azure-vote-app.yaml#L62

example:
`        image: devopsjourneyacr.azurecr.io/devopsjourney:68`

3. Update pipeline in Azure DevOps repo with the below updates:
- [Add Deploy azure-vote-app to AKS Stage](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/4-Deploy-App-AKS/pipelines/lab4pipeline.yaml#L140-L163)
- [Update Values](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/4-Deploy-App-AKS/pipelines/lab4pipeline.yaml#L156-L157)
  - AKS_RG: AKS Resource Group Name 
  - AKS_NAME: AKS Cluster Name
- This script will get AKS credientals and deploy above .yaml file that will deploy azure-vote-app 

4. Test app on K8s cluster

- Review **Services and ingresses** in Azure Portal
  - Select **ingresses** tab and review **azure-vote-front** address

![](images/deploy-app-aks-1.png)

Access IP address, the azure-vote-app will display

![](images/deploy-app-aks-2.png)
