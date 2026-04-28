# 📦 Deploy Python/Flask Application to Azure Container Registry


## 🎯 Learning Objectives

By the end of this lab, you'll be able to:

- Create an ACR service connection using WIF — secretless Docker registry authentication in Azure Pipelines
- Update pipeline variables — point the build stage at your ACR and Dockerfile
- Copy the app folder to your Azure DevOps repo — so the pipeline can build the image
- Run the pipeline — to build and push the Python/Flask Docker image to ACR

> ⏱️ **Estimated Time**: ~20 minutes

## ✅ Prerequisites

Before starting, ensure you have:

- **Docker Desktop** installed (for local testing in [docker-image-locally.md](./docker-image-locally.md))
- **Azure CLI** authenticated
- **Completed [Lab 2 — Terraform Pipeline](../2-AzureDevOps-Terraform-Pipeline/1-Setup-AzureDevOps-Pipeline.md)** — ACR provisioned
- **ACR name** from Terraform output: `devopsjourneyoct2024acr`
- **Azure DevOps project and repository** from Lab 2

---

## 🚀 Step-by-Step Implementation

### Step 1: Test the Docker Image Locally

Before pushing to ACR, verify the image builds and runs correctly on your local machine.

Follow the complete local testing guide: **[docker-image-locally.md](./docker-image-locally.md)**

**Quick validation:**
```bash
cd app
docker build -t devopsjourneyapp:local .
docker run -d -p 5000:5000 devopsjourneyapp:local
curl http://localhost:5000
```

**✅ Expected Output:**
```html
<!DOCTYPE html>
<html>...Flask app response...</html>
```

---

### Step 2: Create an ACR Service Connection (WIF)

The pipeline uses Workload Identity Federation to authenticate to ACR — no passwords or tokens stored.

1. **⚙️ Open Project Settings**

   In your Azure DevOps project → **Project Settings** → **Service connections**.

2. **➕ New service connection**

   Click **New service connection** → **Docker Registry**.

3. **🔧 Configure ACR with WIF**

   - Registry type: **Azure Container Registry**
   - Authentication type: **Workload Identity Federation (automatic)**
   - Select your Azure **Subscription**
   - Select your **Azure Container Registry**: `devopsjourneyoct2024acr`
   - Service connection name: `devopsjourneyoct2024acr`
   - Check **Grant access permission to all pipelines**
   - Click **Save**


   **✅ Expected Output:**
   ```
   Service connection "devopsjourneyoct2024acr" created.
   Authentication type: Workload Identity Federation
   Registry: devopsjourneyoct2024acr.azurecr.io
   ```

---

### Step 3: Copy the Application to Your Azure DevOps Repository

1. **📂 Copy the `app` folder**

   Copy the `app/` directory from this repository into your Azure DevOps repository:

   ```bash
   # In your Azure DevOps repo (cloned locally)
   cp -r /path/to/labs/3-Deploy-App-to-ACR/app ./app
   git add app/
   git commit -m "Add Python/Flask application source"
   git push
   ```

   The `app/` folder contains:
   - `app.py` — Flask 3.1.3 application with `azure-monitor-opentelemetry==1.8.7` instrumentation
   - `requirements.txt` — Python 3.13 dependencies
   - `Dockerfile` — based on `python:3.13-slim`, exposes port `5000`

---

### Step 4: Update the Pipeline YAML

1. **📝 Update pipeline variables**

   Open [`labs/3-Deploy-App-to-ACR/pipelines/lab3pipeline.yaml`](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/3-Deploy-App-to-ACR/pipelines/lab3pipeline.yaml) and update the following variables:

   ```yaml
   variables:
     - name: repository
       value: 'repository'                       # ← ACR repository name
     - name: dockerfile
       value: '$(Build.SourcesDirectory)/app/Dockerfile'
     - name: containerRegistry
       value: 'devopsjourneyoct2024acr'          # ← Your ACR service connection name
     - name: tag
       value: '$(Build.BuildId)'
   ```

2. **🔧 Review the Build stage**

   The pipeline includes a **Build** stage that:
   - Uses `Docker@2` task to build the image from the `app/Dockerfile`
   - Tags the image with `$(Build.BuildId)` for traceability
   - Pushes the image to `devopsjourneyoct2024acr.azurecr.io/repository:$(Build.BuildId)`


3. **💾 Push the updated pipeline to your repo**

   ```bash
   git add pipelines/lab3pipeline.yaml
   git commit -m "Add Docker build stage for Python/Flask app"
   git push
   ```

---

### Step 5: Run the Pipeline and Verify

1. **▶️ Run the pipeline**

   Navigate to **Pipelines** → select your pipeline → **Run pipeline**.

2. **📋 Review the new Build stage**

   You will now see two stages — **Terraform** and **Build**:


3. **🔍 Verify the image in ACR**

   Navigate to **Azure Portal** → **Container registries** → `devopsjourneyoct2024acr` → **Repositories**.


   **✅ Expected Output:**
   ```
   Repository: repository
   Tags:
     626   (pushed 2 minutes ago)
   ```

---

## ✅ Validation

**Infrastructure checklist:**
- ACR service connection appears in Project Settings → Service connections
- Pipeline Build stage completes with green tick
- Image tag visible in ACR repository

**Technical validation:**
```bash
# List images in ACR
az acr repository show-tags \
  --name devopsjourneyoct2024acr \
  --repository repository \
  --orderby time_desc \
  --top 5 \
  -o table

# Pull the image to verify it works (optional)
az acr login --name devopsjourneyoct2024acr
docker pull devopsjourneyoct2024acr.azurecr.io/repository:latest
docker run -d -p 5000:5000 devopsjourneyoct2024acr.azurecr.io/repository:latest
curl http://localhost:5000
```

**✅ Expected Output:**
```
Result
------
626
625
...
```

---

<details>
<summary>🔧 <strong>Troubleshooting</strong> (click to expand)</summary>

```bash
# Problem: Docker build fails with "cannot find Dockerfile"
# Solution: Verify the dockerfile path in pipeline variables
# The Dockerfile should be at: $(Build.SourcesDirectory)/app/Dockerfile
ls $(Build.SourcesDirectory)/app/Dockerfile

# Problem: "unauthorized: authentication required" pushing to ACR
# Solution: Verify the ACR service connection is configured with WIF and the
# WIF identity has AcrPush role on the ACR
az role assignment list \
  --scope "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ContainerRegistry/registries/devopsjourneyoct2024acr" \
  --query "[].{Principal:principalName, Role:roleDefinitionName}" -o table

# Problem: Python build fails with "No matching distribution found"
# Solution: Ensure you're using python:3.13-slim base image and requirements.txt is correct
# Check Dockerfile FROM line:
head -1 app/Dockerfile
# Expected: FROM python:3.13-slim

# Problem: Port 5000 not accessible after docker run
# Solution: Ensure -p 5000:5000 is specified
docker run -d -p 5000:5000 devopsjourneyapp:local
curl http://localhost:5000
```

</details>

---

## � Key Takeaways

1. **WIF uses short-lived OIDC tokens** — no credentials to store, rotate, or leak. The Azure DevOps identity federates with Entra ID to obtain a token at pipeline runtime.
2. **`$(Build.BuildId)` creates unique, traceable tags** — each pipeline run produces a uniquely tagged image. This enables rollbacks to any previous build and ensures you know exactly which pipeline run produced a given image.
3. **`python:3.13-slim` keeps images small** — `slim` variants contain only the minimum packages needed to run Python (~70MB vs ~1GB for full). Smaller images mean faster pulls, smaller attack surface, and lower registry storage costs.
4. **Azure Pipelines builds from the repo** — the pipeline agent checks out the Azure DevOps repository and looks for the Dockerfile relative to `$(Build.SourcesDirectory)`. Files only in GitHub are not accessible to the Azure DevOps pipeline agent.

---

## ➡️ What's Next

Your Docker image is now building and pushing to ACR on every pipeline run. In the next lab you'll configure the pipeline identity's AKS access and store the App Insights connection string securely.

**[← Back to Lab 2](../2-AzureDevOps-Terraform-Pipeline/1-Setup-AzureDevOps-Pipeline.md)** | **[Continue to Lab 4 →](../4-Deploy-App-AKS/1-Update-AD-Group-and-Add-KeyVault-Secret.md)**

---

## 📚 Additional Resources

- 🔗 [Azure Container Registry — Authentication overview](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication)
- 🔗 [Docker task in Azure Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/docker-v2)
- 🔗 [Python 3.13 slim Docker image](https://hub.docker.com/_/python)
- 🔗 [azure-monitor-opentelemetry PyPI](https://pypi.org/project/azure-monitor-opentelemetry/)