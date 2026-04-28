# 👥 Create Azure AD Group for AKS Admins


## 🎯 Learning Objectives

By the end of this lab, you'll be able to:

- Create an Azure AD security group — the group that controls `kubectl` admin access to AKS
- Add your current user to the group — so you can interact with the cluster after it is provisioned
- Record the Group Object ID — used as `admin_object_id` in Terraform to grant Key Vault and AKS admin RBAC

> ⏱️ **Estimated Time**: ~5 minutes

## ✅ Prerequisites

Before starting, ensure you have:

- **Azure CLI** installed and authenticated (`az login`)
- **Bash** terminal
- **Completed [Lab 1.2 — Terraform Remote Storage](./2-Azure-Terraform-Remote-Storage.md)**
- **Sufficient Entra ID permissions** to create groups and add members (at minimum **Groups Administrator** or **User Administrator** role)

---

## 🚀 Step-by-Step Implementation

### Step 1: Run the AD Group Creation Script

1. **▶️ Execute the script**

   ```bash
   cd labs/1-Initial-Setup
   chmod +x scripts/create-azure-ad-group.sh
   ./scripts/create-azure-ad-group.sh
   ```

   **✅ Expected Output:**
   ```
   Creating Azure AD group: devopsjourney-aks-group-apr2026
   Azure AD Group created successfully.
   Group ID: 278cc1b9-653d-464a-90f7-309e02d4b5d1

   Adding current user to group...
   User added successfully.

   ✅ Group setup complete:
      Group Name : devopsjourney-aks-group-apr2026
      Group ID   : 278cc1b9-653d-464a-90f7-309e02d4b5d1
   ```

   **What the script does:**
   - Creates an Entra ID security group named `devopsjourney-aks-group-apr2026`
   - Adds the currently authenticated Azure CLI user as a group member
   - Outputs the **Group Object ID** — copy this, you will need it in Lab 2

2. **📋 Save the Group Object ID**

   > ⚠️ **Important:** Record the Group Object ID printed at the end of the script. You will enter this as `admin_object_id` in the Terraform `production.tfvars` file in Lab 2. This value grants the group:
   > - **Key Vault Administrator** — to read and manage secrets
   > - **AKS Cluster Admin** — for `kubectl` access via `--enable-azure-rbac`

---

### Step 2: Verify Group Creation in the Portal

1. **🌐 Navigate to Azure Portal**

   Go to **Microsoft Entra ID** → **Groups** → search for `devopsjourney-aks-group-apr2026`.

2. **✅ Confirm membership**

   Click the group → **Members** — your user account should appear.


---

## ✅ Validation

**Infrastructure checklist:**
- Group `devopsjourney-aks-group-apr2026` visible in Entra ID → Groups
- Your user account appears as a member
- Group Object ID has been recorded

**Technical validation:**
```bash
# Verify the group exists and get its ID
az ad group show \
  --group "devopsjourney-aks-group-apr2026" \
  --query "{Name:displayName, ID:id}" -o table

# Verify your user is a member
az ad group member list \
  --group "devopsjourney-aks-group-apr2026" \
  --query "[].{UPN:userPrincipalName, Name:displayName}" -o table
```

**✅ Expected Output:**
```
Name                               ID
---------------------------------  ------------------------------------
devopsjourney-aks-group-apr2026    278cc1b9-653d-464a-90f7-309e02d4b5d1

UPN                            Name
-----------------------------  ---------------
you@yourdomain.com             Your Name
```

---

<details>
<summary>🔧 <strong>Troubleshooting</strong> (click to expand)</summary>

```bash
# Problem: "Insufficient privileges to complete the operation"
# Solution: You need Groups Administrator or User Administrator role in Entra ID
# Ask your Azure AD admin to grant the role temporarily, or use the portal

# Problem: Script completes but group ID is not printed
# Solution: Query it manually
az ad group show --group "devopsjourney-aks-group-apr2026" --query id -o tsv

# Problem: Cannot add yourself to the group (no permission)
# Solution: Add via portal or have a Global Admin add you
az ad group member add \
  --group "devopsjourney-aks-group-apr2026" \
  --member-id "$(az ad signed-in-user show --query id -o tsv)"

# Problem: Group already exists from a previous run
# Solution: Retrieve the existing group ID
az ad group show --group "devopsjourney-aks-group-apr2026" --query id -o tsv
```

</details>

---

## � Key Takeaways

1. **Group-based access is scalable and auditable** — adding or removing team members only requires group membership changes, not infrastructure re-deployments. Groups also simplify access reviews.
2. **`admin_object_id` is passed to Terraform** to create two RBAC assignments: (a) **Key Vault Administrator** so the group can manage secrets, and (b) **Azure Kubernetes Service Cluster Admin** so members can run `kubectl` commands against the cluster.
3. **To add the WIF service principal later**: retrieve the SP created by the WIF service connection from Azure DevOps → Project Settings → Service Connections → Manage Workload Identity, then run: `az ad group member add --group devopsjourney-aks-group-apr2026 --member-id <sp-object-id>`
4. **Entra ID RBAC** integrates with your organisation's identity provider — SSO, MFA, and conditional access apply. **Local accounts** (`--disable-local-accounts`) are legacy and bypass Entra ID controls; disabling them is a security best practice.

---

## ➡️ What's Next

You now have an Entra ID admin group ready for AKS RBAC. The Group Object ID will be used as `admin_object_id` in your Terraform variables in Lab 2.

**[← Back to Lab 1.2](./2-Azure-Terraform-Remote-Storage.md)** | **[Continue to Lab 2 →](../2-AzureDevOps-Terraform-Pipeline/1-Setup-AzureDevOps-Pipeline.md)**

---

## 📚 Additional Resources

- 🔗 [Azure AD groups overview](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/how-to-manage-groups)
- 🔗 [AKS — Use Azure RBAC for Kubernetes authorization](https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac)
- 🔗 [AKS — Disable local accounts](https://learn.microsoft.com/en-us/azure/aks/managed-aad#disable-local-accounts)