# Test Lab Only — End-to-End Local Deployment Guide

> ⚠️ **For local/lab testing only.** This bypasses Azure DevOps pipelines and deploys everything directly from your machine using Terraform, Docker, and kubectl. For the full pipeline-based tutorial, follow the numbered labs instead.

## Prerequisites

Ensure the following tools are installed:

| Tool | Minimum Version |
|------|----------------|
| Azure CLI | Latest |
| Terraform | >= 1.14.0 |
| Docker Desktop | Latest |
| kubectl | Latest |

Log in to Azure before running:

```bash
az login
az account set --subscription "<your-subscription-id>"
```

## Configuration

The deploy script uses these environment variables (defaults shown):

```bash
export PROJECT_NAME="devopsjourneyapr2026"   # Prefix for all Azure resources
export LOCATION="uksouth"                     # Azure region
```

> **AKS version note:** The deployment targets Kubernetes `1.33`. Verify it is available in your chosen region:
> ```bash
> az aks get-versions --location uksouth --query "values[].version" -o table
> ```

> **Terraform state note:** The `admin_object_id` in `labs/2-AzureDevOps-Terraform-Pipeline/vars/production.tfvars` must be set to your Azure AD group or user object ID before deploying. See [Lab 1 — Step 3](labs/1-Initial-Setup/3-Create-Azure-AD-AKS-Admins.md).

## Automated Deployment

Run from the **repository root**:

```bash
# Clone the repository
git clone https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps.git
cd DevOps-Journey-Using-Azure-DevOps

# Deploy everything (infrastructure + app)
./scripts/deploy-all.sh

# Clean up all resources when done
./scripts/cleanup-all.sh
```

The deploy script will:
1. Check all prerequisites (az, terraform, docker, kubectl)
2. Verify Azure authentication
3. Create Terraform remote state storage (`devops-journey-rg-apr2026`)
4. Create an Azure AD group for AKS admins
5. Run `terraform init / plan / apply` for all infrastructure (ACR, VNet, Log Analytics, AKS, Key Vault, App Insights) in a single apply
6. Fetch AKS credentials (`kubectl` context configured automatically)
7. Build and push the Python/Flask Docker image to ACR
8. Update `app.yaml` with the correct image reference
9. Deploy the application to Kubernetes and wait for rollout
10. Print the LoadBalancer URL when ready

## What Gets Deployed

| Resource | Name |
|----------|------|
| Resource Group | `devopsjourneyapr2026-rg` |
| AKS Cluster | `devopsjourneyapr2026aks` (K8s 1.33) |
| ACR | `devopsjourneyapr2026acr` |
| Key Vault | `devopsjourneyapr2026kv` |
| App Insights | Workspace-based, connection string |
| Log Analytics | `devopsjourneyapr2026` workspace |
| VNet | `devopsjourney-vnet` (192.168.0.0/16) |
| App | Python 3.13 / Flask 3.1.3 on port 5000 |

## Versions in Use

| Component | Version |
|-----------|---------|
| Terraform | >= 1.14.0, < 2.0.0 |
| Azure Provider (azurerm) | >= 4.68.0, < 5.0.0 |
| AKS Kubernetes | 1.33 |
| Python base image | 3.13-slim |
| Flask | 3.1.3 |
| azure-monitor-opentelemetry | 1.8.7 |
