# Deploying Terraform Using Azure DevOps

The purpose of this lab is to create all of the Azure cloud services you'll need from an environment/infrastructure perspective to run the test application.

I have created modules to deploy the Terraform infrastructure
- [Azure Container Registry](https://github.com/thomast1906/Devops-Journey-Using-Azure-Devops/blob/main/labs/2-AzureDevOps-Terraform-Pipeline/terraform/ACR)
- [Azure Virtual Network](https://github.com/thomast1906/Devops-Journey-Using-Azure-Devops/blob/main/labs/2-AzureDevOps-Terraform-Pipeline/terraform/AKS)
- [Azure Container Registry](https://github.com/thomast1906/Devops-Journey-Using-Azure-Devops/blob/main/labs/2-AzureDevOps-Terraform-Pipeline/terraform/Log-Analytics)
- [Azure Container Registry](https://github.com/thomast1906/Devops-Journey-Using-Azure-Devops/blob/main/labs/2-AzureDevOps-Terraform-Pipeline/terraform/VNET)

In this lab, you will:
- Review Terraform modules mentioned above
- Terraform .tfvars are going to be used, review accordingly
- Deploy terraform using provided Azure DevOps pipeline

