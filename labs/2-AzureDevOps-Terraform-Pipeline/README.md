# Deploying Terraform Using Azure DevOps

## 🎯 Purpose
The purpose of this lab is to create all of the Azure cloud services you'll need from an environment/infrastructure perspective to run the test application.

I have created modules to deploy the Terraform infrastructure, feel free to check them out:
- [Azure Container Registry](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/tree/main/labs/2-AzureDevOps-Terraform-Pipeline/terraform/modules/acr)
- [Azure Virtual Network](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/tree/main/labs/2-AzureDevOps-Terraform-Pipeline/terraform/modules/vnet)
- [Azure Kubernetes Service](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/tree/main/labs/2-AzureDevOps-Terraform-Pipeline/terraform/modules/aks)
- [Azure Log Analytics](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/tree/main/labs/2-AzureDevOps-Terraform-Pipeline/terraform/modules/log-analytics)
- [Azure Application Insights](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/tree/main/labs/2-AzureDevOps-Terraform-Pipeline/terraform/modules/appinsights)

In this lab, you will:
- Review Terraform modules mentioned above
- Terraform .tfvars are going to be used, review accordingly
- Deploy terraform using provided Azure DevOps pipeline

## 🔍 Verification:
1. Confirm you can access and understand each module's structure and purpose

## 🧠 Knowledge Check:
1. What resources does each module create?
2. How do these modules interact with each other?

#### 💡 Pro Tip: Familiarise yourself with the input variables and outputs of each module to understand how they can be customised and integrated.
