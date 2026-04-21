# 🗄️ Configure Terraform Remote State Storage


## 🎯 **Learning Objectives**

By the end of this lab, you will:
- [ ] **Understand why remote Terraform state is essential** — for collaboration, consistency, and locking
- [ ] **Create an Azure Resource Group** — as the logical container for your Terraform backend resources
- [ ] **Provision an Azure Storage Account and Blob Container** — to store and lock the Terraform state file securely

## 📋 **Prerequisites**

**✅ Required Knowledge:**
- [ ] Basic understanding of Terraform state concepts
- [ ] Familiarity with Azure Storage

**🔧 Required Tools:**
- [ ] Azure CLI installed and authenticated (`az login`)
- [ ] Bash (macOS/Linux terminal or WSL on Windows)

**🏗️ Infrastructure Dependencies:**
- [ ] Completed [Lab 1.1 — Azure DevOps Setup](./1-Azure-DevOps-Setup.md)
- [ ] Active Azure subscription with sufficient permissions (Contributor or Owner)

---

## 🚀 **Step-by-Step Implementation**

### **Step 1: Customise the Script Variables**

1. **📂 Open the storage creation script**

   Open [`scripts/create-terraform-storage.sh`](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/1-Initial-Setup/scripts/create-terraform-storage.sh) and update the following variables to match your environment:

   ```bash
   RESOURCE_GROUP_NAME="devops-journey-rg-oct2024"
   STORAGE_ACCOUNT_NAME="devopsjourneyoct2024"
   LOCATION="uksouth"
   CONTAINER_NAME="tfstate"
   ```

   > ⚠️ **Storage account names must be globally unique**, 3–24 characters, lowercase alphanumeric only. Choose a name unique to you.

---

### **Step 2: Run the Script**

1. **▶️ Execute the script**

   ```bash
   cd labs/1-Initial-Setup
   chmod +x scripts/create-terraform-storage.sh
   ./scripts/create-terraform-storage.sh
   ```

   **✅ Expected Output:**
   ```
   Creating resource group: devops-journey-rg-oct2024
   {
     "id": "/subscriptions/.../resourceGroups/devops-journey-rg-oct2024",
     "location": "uksouth",
     "name": "devops-journey-rg-oct2024"
   }
   Creating storage account: devopsjourneyoct2024
   Storage account created successfully.
   Creating blob container: tfstate
   Blob container created successfully.

   ✅ Terraform backend resources created:
      Resource Group : devops-journey-rg-oct2024
      Storage Account: devopsjourneyoct2024
      Container      : tfstate
   ```

**What the script does:**
- [ ] Creates an Azure **Resource Group** for all DevOps journey resources
- [ ] Creates an Azure **Storage Account** with LRS redundancy and HTTPS-only enforcement
- [ ] Creates a **Blob Container** named `tfstate` to store the Terraform state file
- [ ] Enables **blob versioning** and **soft-delete** for state file protection

---

### **Step 3: Record Your Backend Values**

Make note of the following — you will need them in the pipeline YAML configuration in Lab 2:

```bash
# Retrieve storage account key (needed for Terraform backend config)
az storage account keys list \
  --resource-group devops-journey-rg-oct2024 \
  --account-name devopsjourneyoct2024 \
  --query "[0].value" -o tsv
```

> 💡 In this lab we use the WIF service connection for authentication, so the storage key is only needed if you choose key-based backend auth. The pipeline uses the service connection's identity to access the storage account.

---

## ✅ **Validation Steps**

**🔍 Infrastructure Validation:**
- [ ] Resource group `devops-journey-rg-oct2024` exists in Azure Portal
- [ ] Storage account `devopsjourneyoct2024` is present within the resource group
- [ ] Blob container `tfstate` exists inside the storage account

```bash
# Validate resource group
az group show --name devops-journey-rg-oct2024 --query "{Name:name, Location:location, State:properties.provisioningState}" -o table

# Validate storage account
az storage account show \
  --name devopsjourneyoct2024 \
  --resource-group devops-journey-rg-oct2024 \
  --query "{Name:name, SKU:sku.name, HTTPS:enableHttpsTrafficOnly}" -o table

# Validate blob container
az storage container show \
  --name tfstate \
  --account-name devopsjourneyoct2024 \
  --auth-mode login \
  --query "{Name:name, PublicAccess:properties.publicAccess}" -o table
```

**✅ Expected Output:**
```
Name                       Location    State
-------------------------  ----------  ---------
devops-journey-rg-oct2024  uksouth     Succeeded

Name                    SKU         HTTPS
----------------------  ----------  -------
devopsjourneyoct2024    Standard_LRS  True

Name      PublicAccess
--------  ------------
tfstate   None
```

You can also verify visually in the Azure Portal:


---

## 🚨 **Troubleshooting Guide**

**❌ Common Issues:**

```bash
# Problem: Storage account name already taken
# Solution: Choose a different, more unique name
# The name must be 3-24 lowercase alphanumeric characters and globally unique
STORAGE_ACCOUNT_NAME="devopsjourneyoct2024v2"

# Problem: Insufficient permissions to create resource group
# Solution: Ensure your account has Contributor or Owner on the subscription
az role assignment list --assignee "$(az account show --query user.name -o tsv)" \
  --query "[].roleDefinitionName" -o tsv

# Problem: "AuthorizationFailed" on container list
# Solution: Assign yourself Storage Blob Data Contributor on the storage account
az role assignment create \
  --assignee "$(az account show --query user.name -o tsv)" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/devops-journey-rg-oct2024/providers/Microsoft.Storage/storageAccounts/devopsjourneyoct2024"
```

---

## 💡 **Knowledge Check**

**🎯 Questions:**
1. Why must Terraform state be stored remotely rather than locally when working in a team?
2. What is state locking and why is Azure Blob Storage suitable for it?
3. What happens to your infrastructure if the Terraform state file is lost or corrupted?
4. Why should the blob container NOT have public access enabled?

**📝 Answers:**
1. **Remote state enables collaboration** — multiple engineers can run `terraform plan/apply` against the same state without conflicts. Local state is per-developer and leads to drift.
2. **State locking prevents concurrent modifications** — Azure Blob Storage supports lease-based locking so only one `terraform apply` runs at a time. Without locking, parallel runs can corrupt the state.
3. **Terraform loses track of existing resources** — it would try to create all resources again, causing duplication or errors. Always back up state files using versioning and soft-delete.
4. **The state file may contain sensitive values** — secrets, passwords, and keys can appear in plaintext in Terraform state. Public access would expose these to anyone.

---

## 🎯 **Next Steps**

**✅ Upon Completion:**
- [ ] Azure Resource Group created: `devops-journey-rg-oct2024`
- [ ] Storage Account created: `devopsjourneyoct2024`
- [ ] Blob Container created: `tfstate`
- [ ] Backend values noted for use in Lab 2 pipeline

**➡️ Continue to:** [Lab 1.3 — Create Azure AD AKS Admin Group](./3-Create-Azure-AD-AKS-Admins.md)

---

## 📚 **Additional Resources**

- 🔗 [Terraform — Azure Backend configuration](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
- 🔗 [Azure Storage — Blob storage overview](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)
- 🔗 [Azure Storage — Data redundancy options](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy)