# Setting Up CI/CD with Pipeline Triggers for Automatic Runs

## 🎯 Purpose
Configure Azure DevOps pipeline triggers to enable automatic runs on code changes, implementing continuous integration and continuous deployment (CI/CD).

## 1. Current Trigger Configuration

1. Review the existing trigger configuration in your pipeline.

You might have noticed that previous changes to the branch did not trigger the pipeline. This is because the pipeline trigger is currently set to none:

```yaml
trigger: none
```

### 🔍 Verification:
1. Confirm that the current trigger is set to none

### 🧠 Knowledge Check:
1. Why doesn't the pipeline run automatically with the current configuration?
2. What are the implications of having trigger: none?

#### 💡 Pro Tip: Always review your trigger configuration to ensure it aligns with your project's CI/CD requirements.

## 2. Update the Pipeline Trigger

1. Update the pipeline with the following trigger configuration to ensure it runs each time a change is made to the main/master branch. (Rename main/master according to your branch naming convention)

```yaml
trigger:
  batch: true 
  branches:
    include:
      - main
```

### 🔍 Verification:
1. Ensure the YAML syntax is correct
2. Check that the branch name matches your repository's main branch

### 🧠 Knowledge Check:
1. What does the batch: true option do?
2. How does this trigger configuration improve your CI/CD process?

#### 💡 Pro Tip: Consider using branch policies in conjunction with triggers to enforce code quality standards. 

## 3. Edit Your Azure DevOps Pipeline

1. Modify your Azure DevOps pipeline to include this trigger configuration [here](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/5-CICD/pipelines/lab5pipeline.yaml#L3-L7)

### 🔍 Verification:
1. Confirm the changes are saved in your pipeline YAML file
2. Check that the pipeline recognizes the new trigger configuration

### 🧠 Knowledge Check:
1. How does this change affect your development workflow?
2. What other types of triggers could be useful for your project?

#### 💡 Pro Tip: Test your trigger by making a small change to the main branch and observing if the pipeline runs automatically.

Remember:
1. The exact branch name (main/master) should match your repository's naming convention.
2. You can further customise triggers to include or exclude specific paths or file types.
3. Consider implementing additional triggers like pull request triggers or scheduled triggers based on your project needs.
