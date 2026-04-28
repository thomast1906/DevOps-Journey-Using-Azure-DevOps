# 🔄 Introduce CI/CD Pipeline Triggers


## 🎯 Learning Objectives

By the end of this lab, you'll be able to:

- Understand why `trigger: none` prevents automatic runs — and when that is intentional
- Configure a branch-based trigger — so every push to `main` automatically kicks off the pipeline
- Understand `batch: true` — and how it prevents overlapping pipeline runs
- Verify the CI trigger works — by making a test commit and observing automatic execution

> ⏱️ **Estimated Time**: ~10 minutes

## ✅ Prerequisites

Before starting, ensure you have:

- **Git** installed
- **Completed [Lab 4 — Deploy App to AKS](../4-Deploy-App-AKS/2-Update-Pipeline-Deploy-App-AKS.md)**
- **Working pipeline** that successfully runs all stages manually

---

## 🚀 Step-by-Step Implementation

### Step 1: Review the Current Trigger Configuration

Your current pipeline has the following trigger at the top of the YAML:

```yaml
trigger: none
```

This means the pipeline will **only run when manually triggered** from the Azure DevOps UI. No automatic execution occurs on code pushes.

> 💡 `trigger: none` is useful during initial setup and lab development — it prevents accidental pipeline runs. Now that the full pipeline is working, we switch to branch-based CI/CD.

---

### Step 2: Update the Pipeline Trigger

1. **📝 Open your pipeline YAML file**

   Open the pipeline YAML (from Lab 5): [`labs/5-CICD/pipelines/lab5pipeline.yaml`](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/blob/main/labs/5-CICD/pipelines/lab5pipeline.yaml#L3-L7)

2. **✏️ Replace the trigger block**

   Change:
   ```yaml
   trigger: none
   ```

   To:
   ```yaml
   trigger:
     batch: true
     branches:
       include:
         - main
   ```

   **Trigger configuration explained:**
   - `batch: true` — if multiple commits arrive while a run is in progress, they are **batched** into a single run after the current one finishes. This prevents a flood of overlapping pipeline runs during a fast-paced push session.
   - `branches.include: [main]` — only pushes to `main` trigger the pipeline. Feature branches, hotfix branches, and PRs do **not** trigger this pipeline automatically.

3. **💾 Commit and push the change**

   ```bash
   git add pipelines/lab5pipeline.yaml
   git commit -m "Enable CI/CD trigger on main branch"
   git push origin main
   ```

   **✅ Expected Outcome:**
   ```
   The push to main triggers the pipeline automatically.
   You should see a new pipeline run start within ~30 seconds.
   ```

---

### Step 3: Verify Automatic Trigger

1. **🔍 Navigate to Pipelines in Azure DevOps**

   You should see a new run started automatically — triggered by your push, not manually.

2. **📋 Confirm the trigger source**

   Click on the running pipeline → **Summary** tab. The trigger should show:
   ```
   Triggered by: CI — push to main
   Commit: "Enable CI/CD trigger on main branch"
   ```

   **✅ Expected Output:**
   ```
   Run #N — Triggered by CI
   Status: Running
   Stages: Validate ✅ | Build ✅ | Deploy ▶️
   ```

---

## ✅ Validation

**CI/CD checklist:**
- Trigger changed from `none` to branch-based
- Push to `main` automatically starts a new pipeline run
- Pipeline run shows "CI" as the trigger source (not "Manual")
- All pipeline stages complete successfully

**Technical validation:**
```bash
# Verify the trigger is set correctly in the YAML
grep -A 5 "^trigger:" pipelines/lab5pipeline.yaml

# After pushing, check the pipeline run was triggered automatically
# (Azure DevOps CLI — requires az devops extension)
az devops configure --defaults organization=https://dev.azure.com/<your-org> project=DevOps-Journey
az pipelines runs list --pipeline-name <your-pipeline> --top 1 \
  --query "[].{Status:status, Reason:reason, Branch:sourceBranch}" -o table
```

**✅ Expected Output:**
```yaml
trigger:
  batch: true
  branches:
    include:
      - main

Status      Reason    Branch
----------  --------  --------
inProgress  batchedCI refs/heads/main
```

---

<details>
<summary>🔧 <strong>Troubleshooting</strong> (click to expand)</summary>

```bash
# Problem: Push to main does not trigger the pipeline
# Solution 1: Check branch name — is it "main" or "master"?
git branch --show-current
# Update trigger if needed:
# branches:
#   include:
#     - master   ← if your default branch is master

# Solution 2: Ensure the pipeline YAML is committed on the same branch as the trigger
git log --oneline -3

# Problem: Pipeline triggers on every commit during active development (spam)
# Solution: Use batch: true (already configured) or add path filters
trigger:
  batch: true
  branches:
    include:
      - main
  paths:
    exclude:
      - '**/*.md'   # Don't trigger on docs-only changes

# Problem: Pipeline runs twice (once from trigger, once from manual run)
# Solution: Cancel the manual run; with batch: true only one will be queued

# Problem: "Pipeline already running" when batch is not enabled
# Solution: Ensure batch: true is set to merge concurrent pushes into one run
```

</details>

---

## � Key Takeaways

1. **`trigger: none` disables automatic triggering** — the pipeline only runs when manually started. It is useful during initial setup or when you want full control over when deployments happen.
2. **`batch: true` queues concurrent commits** — if commits are pushed while a pipeline run is in progress, they are batched together and processed as a single run once the current run finishes. Without batching, every commit would queue its own run.
3. **Use the `paths` filter** to only trigger on relevant changes, for example `app/**` to skip doc-only commits.
4. **CI trigger (`trigger:`) fires on pushes** to the specified branch. **PR trigger (`pr:`)** fires when a pull request is opened or updated targeting the specified branch — for code review validation before merge.

---

## ➡️ What's Next

Your pipeline now triggers automatically on every push to `main`. In the next lab you'll switch to the `latest` Docker tag so every pipeline run automatically rolls out the newest image to AKS.

**[← Back to Lab 4.2](../4-Deploy-App-AKS/2-Update-Pipeline-Deploy-App-AKS.md)** | **[Continue to Lab 5.2 →](./2-Automated-Deployment-AKS-Application.md)**

---

## 📚 Additional Resources

- 🔗 [Azure Pipelines — Triggers](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/trigger)
- 🔗 [Azure Pipelines — CI trigger batching](https://learn.microsoft.com/en-us/azure/devops/pipelines/build/triggers?view=azure-devops#batching-ci-runs)
- 🔗 [Azure Pipelines — Path filters](https://learn.microsoft.com/en-us/azure/devops/pipelines/build/triggers?view=azure-devops#paths)
