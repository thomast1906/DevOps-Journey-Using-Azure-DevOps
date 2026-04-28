# 🔑 Configure AD Group, App Insights Connection String & Key Vault


## 🎯 Learning Objectives

By the end of this lab, you'll be able to:

- Add the WIF service principal to the AKS admin AD group — so the pipeline can authenticate to AKS for deployments
- Retrieve the Application Insights connection string — required by the `azure-monitor-opentelemetry` SDK
- Store the connection string as a Key Vault secret — so the pipeline can inject it securely into Kubernetes
- Create an Azure DevOps variable group — linking the Key Vault secret for use in the pipeline

> ⏱️ **Estimated Time**: ~15 minutes

## ✅ Prerequisites

Before starting, ensure you have:

- **Azure CLI** authenticated (`az login`)
- **Completed [Lab 3 — Deploy App to ACR](../3-Deploy-App-to-ACR/1-Deploy-App-to-ACR.md)**
- **AKS, Key Vault, and Application Insights** provisioned by Terraform (Lab 2)
- **Entra ID group** `devopsjourney-aks-group-oct2024` created (Lab 1.3)

---

## 🚀 Step-by-Step Implementation

### Step 1: Add the WIF Service Principal to the AKS Admin Group

The Workload Identity Federation service principal needs to be a member of the `devopsjourney-aks-group-oct2024` group. This grants the pipeline identity **AKS Cluster Admin** RBAC to run `kubectl apply` during the deploy stage.

1. **🔍 Find the WIF service principal**

   In Azure DevOps → **Project Settings** → **Service connections** → click your ARM service connection (e.g., `azure-devops-journey-oct2024`) → **Manage Workload Identity**.

   Note the **Object ID** of the Enterprise Application / Service Principal.


   Or find it via CLI:
   ```bash
   # List service principals — find the one matching your WIF identity name
   az ad sp list \
     --display-name "azure-devops-journey-identity" \
     --query "[].{Name:displayName, ObjectId:id}" -o table
   ```

2. **➕ Add the service principal to the AKS admin group**

   ```bash
   # Get the WIF service principal object ID
   SP_OBJ_ID=$(az ad sp list \
     --display-name "azure-devops-journey-identity" \
     --query "[0].id" -o tsv)

   # Add to the AKS admin group
   az ad group member add \
     --group "devopsjourney-aks-group-oct2024" \
     --member-id "$SP_OBJ_ID"

   echo "✅ Added $SP_OBJ_ID to devopsjourney-aks-group-oct2024"
   ```

   **✅ Expected Output:**
   ```
   ✅ Added a1b2c3d4-... to devopsjourney-aks-group-oct2024
   ```

3. **🔍 Verify group membership**

   ```bash
   az ad group member list \
     --group "devopsjourney-aks-group-oct2024" \
     --query "[].{Name:displayName, Type:userType}" -o table
   ```


---

### Step 2: Get the Application Insights Connection String

> ⚠️ **Important**: The app uses `azure-monitor-opentelemetry==1.8.7` which requires the **full Connection String** — NOT just the Instrumentation Key. The connection string includes endpoint URLs needed by the OpenTelemetry exporter. The environment variable name is `APPLICATIONINSIGHTS_CONNECTION_STRING`.

1. **📋 Retrieve the connection string via Azure CLI**

   ```bash
   # Install the extension if not already present
   az extension add --name application-insights --only-show-errors

   # Get the connection string (update RG and AI name to your values)
   az monitor app-insights component show \
     --app devopsjourneyoct2024ai \
     -g devopsjourneyoct2024-rg \
     --query connectionString \
     -o tsv
   ```

   **✅ Expected Output:**
   ```
   InstrumentationKey=8896c09a-a3e3-4a72-9914-f826e85c6a5f;IngestionEndpoint=https://uksouth-1.in.applicationinsights.azure.com/;LiveEndpoint=https://uksouth.livediagnostics.monitor.azure.com/;ApplicationId=abc12345-...
   ```

   > 💡 You can also find this in the Azure Portal: **Application Insights** → your resource → **Overview** → **Connection String** (copy button).

2. **📋 Save the full connection string**

   Copy the entire value starting with `InstrumentationKey=...` — you will use this in the next step.

---

### Step 3: Store the Connection String in Key Vault

The pipeline reads the connection string from Key Vault and injects it as a Kubernetes secret. The Python app reads `APPLICATIONINSIGHTS_CONNECTION_STRING` at startup.

1. **🔐 Add the secret to Key Vault**

   ```bash
   # Store the full connection string as secret "AIKEY"
   CONN_STRING=$(az monitor app-insights component show \
     --app devopsjourneyoct2024ai \
     -g devopsjourneyoct2024-rg \
     --query connectionString \
     -o tsv)

   az keyvault secret set \
     --vault-name "devopsjourneyoct2024-kv" \
     --name "AIKEY" \
     --value "$CONN_STRING"
   ```

   **✅ Expected Output:**
   ```json
   {
     "id": "https://devopsjourneyoct2024-kv.vault.azure.net/secrets/AIKEY/...",
     "name": "AIKEY",
     "value": "InstrumentationKey=...;IngestionEndpoint=...;LiveEndpoint=..."
   }
   ```

2. **✅ Verify the secret**

   ```bash
   az keyvault secret show \
     --vault-name "devopsjourneyoct2024-kv" \
     --name "AIKEY" \
     --query "{Name:name, Value:value}" \
     -o table
   ```

---

### Step 4: Create an Azure DevOps Variable Group

The variable group links to Key Vault and makes the `AIKEY` secret available to pipelines as `$(AIKEY)`.

1. **📚 Navigate to Pipelines → Library**

   In Azure DevOps → **Pipelines** → **Library** → **+ Variable group**.

2. **🔧 Configure the variable group**

   - **Variable group name**: `devopsjourney`
   - **Link secrets from an Azure key vault as variables**: Toggle **ON**
   - **Azure subscription**: Select your WIF service connection
   - **Key vault name**: `devopsjourneyoct2024-kv`
   - Click **+ Add** → select `AIKEY`
   - Click **Save**


3. **✅ Verify the variable group**

   The variable group `devopsjourney` should show `AIKEY` as a linked Key Vault secret (displayed as `****`).

---

## ✅ Validation

**Infrastructure checklist:**
- WIF service principal is a member of `devopsjourney-aks-group-oct2024`
- Key Vault secret `AIKEY` contains the full App Insights connection string
- Azure DevOps variable group `devopsjourney` is created and linked to Key Vault

**Technical validation:**
```bash
# Verify WIF SP is in the group
az ad group member check \
  --group "devopsjourney-aks-group-oct2024" \
  --member-id "$(az ad sp list --display-name 'azure-devops-journey-identity' --query '[0].id' -o tsv)"

# Verify Key Vault secret exists (shows name only, not value)
az keyvault secret list \
  --vault-name "devopsjourneyoct2024-kv" \
  --query "[?name=='AIKEY'].{Name:name, Enabled:attributes.enabled}" -o table

# Verify connection string format
AIKEY=$(az keyvault secret show \
  --vault-name "devopsjourneyoct2024-kv" \
  --name "AIKEY" \
  --query value -o tsv)
echo "$AIKEY" | grep -c "InstrumentationKey=" && echo "✅ Connection string format valid"
```

**✅ Expected Output:**
```
{
  "value": true
}

Name    Enabled
------  -------
AIKEY   True

✅ Connection string format valid
```

---

<details>
<summary>🔧 <strong>Troubleshooting</strong> (click to expand)</summary>

```bash
# Problem: "Insufficient privileges" adding SP to group
# Solution: Use a user with Group Administrator or User Administrator role
# Or do it in the Azure Portal: Entra ID → Groups → devopsjourney-aks-group-oct2024 → Members → Add

# Problem: Key Vault access denied when setting secret
# Solution: Ensure your user has Key Vault Administrator RBAC on the vault
az role assignment create \
  --assignee "$(az account show --query user.name -o tsv)" \
  --role "Key Vault Administrator" \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/devopsjourneyoct2024-rg/providers/Microsoft.KeyVault/vaults/devopsjourneyoct2024-kv"

# Problem: Variable group cannot read Key Vault (pipeline fails)
# Solution: Ensure the WIF service connection has Key Vault Secrets User role on the Key Vault
az role assignment create \
  --assignee "<wif-sp-object-id>" \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/<sub-id>/resourceGroups/devopsjourneyoct2024-rg/providers/Microsoft.KeyVault/vaults/devopsjourneyoct2024-kv"

# Problem: App Insights resource not found by CLI
# Solution: List all App Insights in the resource group
az monitor app-insights component list \
  -g devopsjourneyoct2024-rg \
  --query "[].{Name:name, Kind:kind}" -o table
```

</details>

---

## � Key Takeaways

1. **The AKS cluster uses Azure RBAC** — the admin group has **Azure Kubernetes Service Cluster Admin** role. The pipeline's WIF service principal must be a group member to run `az aks get-credentials` and execute `kubectl apply` during the deployment stage.
2. **The connection string is required, not just the Instrumentation Key** — the `azure-monitor-opentelemetry` SDK uses the OpenTelemetry Azure Monitor exporter, which needs the full `InstrumentationKey=...;IngestionEndpoint=...;LiveEndpoint=...` string to reach the correct regional endpoint.
3. **Key Vault provides secret governance** — rotation, access auditing, RBAC, and soft-delete protection. Pipeline variables (even marked secret) are stored in Azure DevOps and lack the enterprise controls of Key Vault.
4. **The Kubernetes deployment manifest** references a Kubernetes secret `aikey`. The pipeline creates this secret from `$(AIKEY)` (the variable group value), and the pod receives `APPLICATIONINSIGHTS_CONNECTION_STRING` as an environment variable at startup.

---

## ➡️ What's Next

The pipeline identity has AKS access and the App Insights connection string is securely stored. In the next lab you'll add the Deploy stage to push the application to AKS.

**[← Back to Lab 3](../3-Deploy-App-to-ACR/1-Deploy-App-to-ACR.md)** | **[Continue to Lab 4.2 →](./2-Update-Pipeline-Deploy-App-AKS.md)**

---

## 📚 Additional Resources

- 🔗 [Application Insights — Connection strings](https://learn.microsoft.com/en-us/azure/azure-monitor/app/sdk-connection-string)
- 🔗 [azure-monitor-opentelemetry — PyPI](https://pypi.org/project/azure-monitor-opentelemetry/)
- 🔗 [Azure DevOps — Link secrets from Key Vault](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault)
- 🔗 [AKS — Azure RBAC integration](https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac)