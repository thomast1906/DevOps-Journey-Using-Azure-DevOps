# Setting Up CI/CD with Pipeline Triggers for Automatic Runs

In Azure DevOps, triggers allow pipelines to run automatically. In this lab, we will configure a trigger to automatically run the pipeline whenever there is a change to the main/master branch.

1. Current Trigger Configuration
 
You might have noticed that previous changes to the branch did not trigger the pipeline. This is because the pipeline trigger is currently set to none.

`trigger: none`

2. Update the Pipeline Trigger


Update the pipeline with the following trigger configuration to ensure it runs each time a change is made to the main/master branch. (Rename main/master according to your branch naming convention)


```
trigger:
  batch: true 
  branches:
    include:
      - main
```

3. Edit Your Azure DevOps Pipeline

Modify your Azure DevOps pipeline to include this trigger configuration [here](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/5-CICD/pipelines/lab5pipeline.yaml#L3-L7)
