# Deploy Sample Application to AKS Cluster

## 🚀 Lab Objective
Deploy the Python/Flask application to your AKS cluster, with Application Insights telemetry injected securely via Kubernetes secrets.

### Lab Overview
You will:
- Add the pipeline service principal to the AKS admin Azure AD group
- Retrieve the Application Insights **Connection String** and store it in Key Vault as secret `AIKEY`
- Create an Azure DevOps variable group (`devopsjourney`) linked to Key Vault secrets
- Update the pipeline to deploy the app to AKS with the App Insights connection string injected as `APPLICATIONINSIGHTS_CONNECTION_STRING`

### Key Architecture Points
| Aspect | Details |
|---|---|
| App Insights telemetry | Uses **connection string** (not legacy instrumentation key) |
| Secret management | Key Vault → AzDO variable group `$(AIKEY)` → K8s secret `aikey` → pod env var |
| Env var name in pod | `APPLICATIONINSIGHTS_CONNECTION_STRING` |
| App port | `5000` (Service `targetPort: 5000`, exposed on port `80`) |
| AKS auth | Workload Identity Federation — no kubeconfig secrets needed |

> ⚠️ **`$(AIKEY)` must be the full App Insights Connection String**, not just the instrumentation key.  
> Format: `InstrumentationKey=xxx;IngestionEndpoint=https://...;LiveEndpoint=https://...`  
> Found in: Azure Portal → Application Insights → Overview → Connection String

### Lab Steps
1. [Update AD Group & Add KeyVault Secret](1-Update-AD-Group-and-Add-KeyVault-Secret.md) — Service principal group membership, Key Vault secret, variable group
2. [Update Pipeline & Deploy to AKS](2-Update-Pipeline-Deploy-App-AKS.md) — Pipeline changes, app.yaml, test the deployed application
