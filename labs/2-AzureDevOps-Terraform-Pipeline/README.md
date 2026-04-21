# Deploying Terraform Using Azure DevOps

## 🚀 Lab Objective
Provision all Azure infrastructure required to run the application — using Terraform deployed via Azure DevOps pipelines.

### Lab Overview
You will:
- Review and configure the Terraform modules for AKS, Key Vault, App Insights, Log Analytics, and networking
- Update `production.tfvars` with your environment values (including `admin_object_id`)
- Deploy Terraform using the provided Azure DevOps pipeline with Workload Identity Federation authentication

### Infrastructure Provisioned
| Resource | Details |
|---|---|
| AKS Cluster | Kubernetes **1.33**, auto-scaling, `patch` upgrade channel, availability zones |
| Key Vault | RBAC-based, **purge protection enabled** (7-day soft-delete) |
| Application Insights | Workspace-based, connected to Log Analytics |
| Log Analytics | Workspace for AKS container insights |
| Virtual Network | AKS node subnet + Application Gateway subnet |
| ACR | Azure Container Registry for app images |

> **⚠️ Re-running the lab:** Key Vault purge protection is enabled. If you delete resources and re-run within 7 days, use a different `general_name` value to avoid name conflicts. Azure automatically purges soft-deleted vaults after the retention period.

### Terraform Stack
| Component | Version |
|---|---|
| Terraform | `>= 1.14.0, < 2.0.0` |
| AzureRM Provider | `>= 4.68.0, < 5.0.0` |

### Key Configuration File
`vars/production.tfvars` — update all values for your environment:
- `general_name` — unique prefix for all resources (e.g. `devopsjourneyoct2024`)
- `admin_object_id` — Object ID for Key Vault Administrator role (your user or service principal)
- `aks_admins_group_object_id` — Object ID of the AKS admins AD group created in Lab 1
  ```bash
  az ad group show --group "AKS-Cluster-Admins" --query id -o tsv
  ```

### Lab Steps
1. [Setup Azure DevOps Pipeline](1-Setup-AzureDevOps-Pipeline.md) — Install Terraform extension, configure pipeline YAML, run Terraform deploy

