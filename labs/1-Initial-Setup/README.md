# Initial Setup

## 🚀 Lab Objective
Set up all necessary Azure cloud services and resources required before deploying additional Azure resources using Terraform.

### Lab Overview
You will:
- Configure Azure DevOps organisation, project, and repository
- Create an Azure DevOps **Workload Identity Federation (OIDC)** service connection — the recommended, secretless authentication method for pipelines
- Establish remote Azure Blob Storage for Terraform state files
- Create an Azure AD group for AKS admins (used for RBAC access to the AKS cluster and Key Vault)

### Prerequisites
- Azure subscription with Owner or Contributor + User Access Administrator permissions
- Azure CLI installed and logged in (`az login`)
- Azure DevOps organisation (free at [dev.azure.com](https://dev.azure.com))

### Key Concepts
| Concept | Details |
|---|---|
| Workload Identity Federation | OIDC-based, no client secrets to rotate — preferred over Service Principal with password |
| Terraform remote state | Stored in Azure Blob Storage; enables team collaboration and state locking |
| Azure AD AKS Admin Group | Object ID used by Terraform to configure Key Vault RBAC and AKS admin access |

### Lab Steps
1. [Azure DevOps Setup](1-Azure-DevOps-Setup.md) — Organisation, project, WIF service connection
2. [Terraform Remote Storage](2-Azure-Terraform-Remote-Storage.md) — Storage account and blob container for state
3. [Create AKS Admin Group](3-Create-Azure-AD-AKS-Admins.md) — Azure AD group for cluster admin access
