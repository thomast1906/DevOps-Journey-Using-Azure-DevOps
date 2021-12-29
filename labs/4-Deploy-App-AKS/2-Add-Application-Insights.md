# Add Application Insights to Terraform

Application Insights will be used to monitor the application once deployed!

1. Deploy Application Insights using this module: 

- [Application Insights](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/tree/main/labs/4-Deploy-App-AKS/terraform/modules/appinsights)

2. Update main.tf with Application Insights module:

https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/4-Deploy-App-AKS/terraform/main.tf#L71-L77


3. Update variables.tf

https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/4-Deploy-App-AKS/terraform/variables.tf#L76-L84

4. Add new .tfvars to https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/4-Deploy-App-AKS/vars/production.tfvars#L23-L25

`app_insights_name = "devopsjourney"\
 application_type  = "web"`

5. Edit your Azure DevOps pipeline to run this pipeline: https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/4-Deploy-App-AKS/pipelines/lab4pipeline.yaml 