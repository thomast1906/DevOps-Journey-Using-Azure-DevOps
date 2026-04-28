# 🚀 Azure DevOps Setup


## 🎯 Learning Objectives

By the end of this lab, you'll be able to:

- Create an Azure DevOps organisation and project — your central hub for all pipeline and repo work
- Configure a Workload Identity Federation (WIF) service connection — the secure, secretless way to authenticate to Azure
- Assign appropriate RBAC roles — so pipelines can provision and manage Azure resources

> ⏱️ **Estimated Time**: ~20 minutes

## ✅ Prerequisites

Before starting, ensure you have:

- **Microsoft account** (free)
- **Active Azure subscription** with Owner or Contributor access
- **Azure CLI** installed and authenticated (`az --version`)
- **Basic familiarity** with Azure portal navigation and CI/CD concepts

> This is the first lab — no prior labs are required.

---

## 🚀 Step-by-Step Implementation

### Step 1: Create an Azure DevOps Organisation

1. **🌐 Sign in to Azure DevOps**

   Navigate to [https://go.microsoft.com/fwlink/?LinkId=307137](https://go.microsoft.com/fwlink/?LinkId=307137) and sign in with your Microsoft account.

2. **🏢 Create a new organisation** (if you don't already have one)

   Click **New organization**, accept the terms of service, and choose a unique organisation name (e.g., `devopsjourneyoct2024`).

3. **📁 Create a new project**

   - Select your organisation
   - Click **New Project**
   - Enter a project name (e.g., `DevOps-Journey`) and description
   - Set visibility to **Private**
   - Click **Create**


   **✅ Expected Output:**
   ```
   Project "DevOps-Journey" created successfully.
   Your new project dashboard is now visible.
   ```

---

### Step 2: Create a Workload Identity Federation Service Connection

Workload Identity Federation (WIF/OIDC) is the **recommended, secretless** way to authenticate Azure DevOps pipelines to Azure. No service principal secrets or certificates are stored.

1. **⚙️ Open Project Settings**

   Inside your new Azure DevOps project, click **Project Settings** (bottom-left cog icon).

2. **🔗 Navigate to Service Connections**

   Select **Service connections** → **New service connection**.

3. **🆔 Choose Azure Resource Manager with WIF**

   - Select **Azure Resource Manager**
   - Select **Workload Identity federation (Automatic)**
   - Click **Next**

4. **🔧 Configure the connection**

   - Choose your Azure **Subscription**
   - Leave Resource Group blank (subscription-scope)
   - Enter a meaningful **Service Connection Name** (e.g., `azure-devops-journey-oct2024`)
   - Check **Grant access permission to all pipelines**
   - Click **Save**


   **✅ Expected Output:**
   ```
   Service connection "azure-devops-journey-oct2024" created.
   Authentication type: Workload Identity Federation
   ```

5. **🔍 Review the Workload Identity details**

   Click **Manage Workload Identity** to inspect the federated credential in Entra ID.


6. **✏️ Rename the Managed Identity**

   Inside **Manage Workload Identity**, update the display name to something meaningful (e.g., `azure-devops-journey-identity`) — removing the auto-generated random suffix.


---

### Step 3: Assign RBAC Roles to the Workload Identity

The pipeline identity needs sufficient Azure permissions to provision infrastructure.

1. **🔑 Assign Owner or User Access Administrator role**

   The Workload Identity requires **Owner** (or at minimum **Contributor** + **User Access Administrator**) at the subscription scope — this is needed to assign RBAC roles during AKS and Key Vault deployment.

   ```bash
   # Get the service principal object ID (replace with your WIF app name)
   SP_OBJ_ID=$(az ad sp list --display-name "azure-devops-journey-identity" \
     --query "[0].id" -o tsv)

   # Assign User Access Administrator at subscription scope
   az role assignment create \
     --assignee "$SP_OBJ_ID" \
     --role "User Access Administrator" \
     --scope "/subscriptions/$(az account show --query id -o tsv)"
   ```

   Or use the Azure Portal:
   - Go to **Subscriptions** → your subscription → **Access control (IAM)**
   - Click **Add** → **Add role assignment**
   - Role: **User Access Administrator**, assign to your WIF service principal


   **✅ Expected Output:**
   ```json
   {
     "roleDefinitionName": "User Access Administrator",
     "principalType": "ServicePrincipal",
     "scope": "/subscriptions/<your-subscription-id>"
   }
   ```

---

## ✅ Validation

**Infrastructure checklist:**
- Azure DevOps project is visible at `https://dev.azure.com/<your-org>/DevOps-Journey`
- Service connection appears under **Project Settings → Service connections**
- Service connection status shows **"Verified"** (green tick)
- Workload Identity appears in **Entra ID → App registrations**
- Role assignment is visible in **Subscription → IAM → Role assignments**

**Technical validation:**
```bash
# Verify the service principal exists
az ad sp list --display-name "azure-devops-journey-identity" \
  --query "[].{Name:displayName, AppId:appId}" -o table

# Verify role assignment
az role assignment list \
  --assignee "$(az ad sp list --display-name 'azure-devops-journey-identity' --query '[0].id' -o tsv)" \
  --query "[].{Role:roleDefinitionName, Scope:scope}" -o table
```

---

<details>
<summary>🔧 <strong>Troubleshooting</strong> (click to expand)</summary>

```bash
# Problem: Service connection verification fails
# Solution: Ensure the WIF identity has at least Contributor at subscription scope
az role assignment create \
  --assignee "<sp-object-id>" \
  --role "Contributor" \
  --scope "/subscriptions/<subscription-id>"

# Problem: "Insufficient privileges" when creating WIF connection
# Solution: You need Owner or Application Administrator role in Entra ID
# Ask your Azure AD admin to grant you the Application Administrator role

# Problem: Workload Identity shows random name after creation
# Solution: Navigate to Manage Workload Identity → Branding → update display name
```

</details>

---

## � Key Takeaways

1. **WIF uses short-lived OIDC tokens** — no secrets to rotate, leak, or expire. Authentication is based on federated trust between Azure DevOps and Entra ID.
2. **User Access Administrator is required** — to create role assignments for managed identities and AKS RBAC resources during Terraform apply.
3. **Automatic WIF** lets Azure DevOps create the Entra ID app registration automatically; **Manual** requires you to provide an existing app registration's federation details.
4. **Subscription-scope role assignment is required** — infrastructure spans multiple resource groups, so the pipeline can create all required resources without per-RG grants.

---

## ➡️ What's Next

You now have Azure DevOps set up with a Workload Identity Federation service connection. The pipeline identity is ready to provision Azure resources without any stored secrets.

**[← Back to Lab Overview](./README.md)** | **[Continue to Lab 1.2 →](./2-Azure-Terraform-Remote-Storage.md)**

---

## 📚 Additional Resources

- 🔗 [Azure DevOps — Create a project](https://learn.microsoft.com/en-us/azure/devops/organizations/projects/create-project)
- 🔗 [Workload Identity Federation for Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops#workload-identity-federation)
- 🔗 [Azure RBAC built-in roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)
