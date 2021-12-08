# Using Inspec-Azure to test your Azure Resources

Inspec-Azure is a resource pack provided by Chef that uses the Azure REST API, to allow you to write tests for resources that you have deployed in Microsoft Azure. These tests can be used to validate the Azures resources that were deployed via code using Terraform or Azure RM templates. Inspec is an open source framework that is used for testing and auditing your infrastructure, in this blog post I will show how you can create tests against your Azure resources using Inspec-Azure.


1. You may have noticed prior changes to this branch didn't automatically run the pipeline. This is because the pipeline trigger is set to none. 

`trigger: none`


2. Update pipeline with trigger below - this will run the pipeline each time a change has been made to the main/master branch. *( Rename main/master as per your branch naming)*

`trigger:
  batch: true 
  branches:
    include:
      - master`

3. Edit your Azure DevOps pipeline to run this pipeline: https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/5-CICD/pipelines/lab5pipeline.yaml#L3-L7

