# Setting Up Azure DevOps Pipeline for Terraform Deployment

Follow these steps to configure Azure DevOps for deploying your Terraform configurations into Azure.

1. Install the Terraform extension/task from [here](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks) into your Azure DevOps organisation

This extension allows you to run Terraform commands within Azure Build and Release Pipelines, supporting the following commands:

- `init`
- `validate`
- `plan`
- `apply`
- `destroy`

2. Create an Azure repository

Navigate to Repos in Azure DevOps. Here, you will find various options to set up a repository. Create a new repository to store your code. Note that this repository will be used for subsequent labs as well.

3. Copy contents from this folder into the newly created Azure DevOps repository

4. Once copied to Azure DevOps repository, Select **Repo** -> **Setup Build**

![](images/azuredevops-terraform-pipeline-3.png)

5. Select **Existing Azure Pipelines YAML file** and branch  / path to the .yaml Azure DevOps Pipeline

![](images/azuredevops-terraform-pipeline.png)

6. Save pipeline and run

![](images/azuredevops-terraform-pipeline-2.png)