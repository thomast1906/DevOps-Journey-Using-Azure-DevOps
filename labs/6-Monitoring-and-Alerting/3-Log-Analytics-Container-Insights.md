# 📊 Log Analytics & Container Insights


## 🎯 Learning Objectives

By the end of this lab, you'll be able to:

- Navigate Container Insights — Cluster, Nodes, Controllers, and Containers perspectives
- Interpret cluster performance metrics — CPU, memory, node count, and pod count charts
- Write KQL queries — to search container logs and diagnose issues from Log Analytics
- Set up log-based alerts — to trigger on error patterns in application logs

> ⏱️ **Estimated Time**: ~20 minutes

## ✅ Prerequisites

Before starting, ensure you have:

- **Azure Portal** access
- **`kubectl`** (for validation commands)
- **Completed [Lab 6.2 — Availability Tests](./2-Application-Insights-Configure-Availability-Test.md)**
- **AKS 1.33 cluster** with Container Insights enabled (provisioned by Terraform in Lab 2)
- **Log Analytics workspace** connected to both the AKS cluster and Application Insights

---

## 🏗️ How Container Insights Works

```
AKS Cluster (1.33)
  └── Container Insights add-on
        ├── Collects: container stdout/stderr logs
        ├── Collects: CPU/memory metrics per pod and node
        └── Sends to: Log Analytics Workspace (devopsjourneyapr2026-law)
              ├── Table: ContainerLog / ContainerLogV2
              ├── Table: KubePodInventory
              ├── Table: KubeNodeInventory
              └── Table: Perf (CPU/memory metrics)
```

> 💡 Container Insights is enabled by the `oms_agent` add-on in your Terraform AKS configuration (`oms_agent { log_analytics_workspace_id = ... }`). The same workspace also receives data from Application Insights — enabling cross-resource KQL queries.

---

## 🚀 Step-by-Step Implementation

### Step 1: Navigate to Container Insights

1. **🌐 Open the Azure Portal**

   Go to [portal.azure.com](https://portal.azure.com) → **Kubernetes services** → `devopsjourneyapr2026aks`.

2. **📊 Open Insights**

   In the left pane → **Monitoring** → **Insights**.

   > Alternatively: Azure Monitor → **Containers** → select your cluster from the multi-cluster view.

3. **🔍 Verify data is flowing**

   The default view shows four line charts — if data is present, Container Insights is working correctly.

---

### Step 2: Cluster Perspective

The **Cluster** tab shows aggregated performance metrics for the entire cluster.


**The four performance charts:**

| Chart | Description | Percentile Filters |
|-------|-------------|-------------------|
| **Node CPU utilization %** | Aggregate CPU across all nodes | Avg, Min, 50th, 90th, 95th, Max |
| **Node memory utilization %** | Aggregate memory across all nodes | Avg, Min, 50th, 90th, 95th, Max |
| **Node count** | Total, Ready, Not Ready node counts | Total, Ready, Not Ready |
| **Active pod count** | Pod count by status | Total, Pending, Running, Unknown, Succeeded, Failed |

**🔍 What to look for:**
- CPU > 80% sustained → consider scaling up node pools or adding nodes
- Memory > 85% sustained → memory pressure, risk of OOM evictions
- Not Ready nodes > 0 → node health issue, investigate immediately
- Pending pods > 0 for extended time → scheduling failure (insufficient resources)

---

### Step 3: Nodes Perspective

1. **🖥️ Switch to Nodes tab**

   Click the **Nodes** tab at the top.

2. **🔍 What to review:**
   - Expand any node to see the pods running on it
   - Click a pod to see its CPU/memory usage over time
   - Identify which pods are consuming the most resources on each node

3. **📋 Useful insight:**
   If your Flask app pod shows high memory growth over time, this may indicate a memory leak — correlate with Application Insights to find the root cause.

---

### Step 4: Containers Perspective

1. **📦 Switch to Containers tab**

   Click the **Containers** tab.

2. **🔍 Filter by namespace:**
   - Set **Namespace** filter to `thomasthorntoncloud`
   - Find your Flask application container

3. **📋 Click the container name** to open:
   - Live container logs (last 1000 lines)
   - CPU and memory charts for that specific container

   > 💡 Live logs from this view use the **Container Insights log stream** — useful for quick debugging without `kubectl logs`.

---

### Step 5: KQL Queries in Log Analytics

Container Insights stores all data in Log Analytics — you can query it with KQL.

1. **🔍 Open Log Analytics**

   Azure Portal → **Log Analytics workspaces** → `devopsjourneyapr2026-law` → **Logs**.

2. **📋 Useful KQL queries:**

   **Pod status over the last hour:**
   ```kql
   KubePodInventory
   | where TimeGenerated > ago(1h)
   | where Namespace == "thomasthorntoncloud"
   | summarize count() by PodStatus, bin(TimeGenerated, 5m)
   | render timechart
   ```

   **Application container logs (last 30 minutes):**
   ```kql
   ContainerLogV2
   | where TimeGenerated > ago(30m)
   | where PodNamespace == "thomasthorntoncloud"
   | where ContainerName contains "devopsjourney"
   | project TimeGenerated, LogMessage, PodName
   | order by TimeGenerated desc
   ```

   **Pod restart count (identify crash-looping pods):**
   ```kql
   KubePodInventory
   | where TimeGenerated > ago(1h)
   | where Namespace == "thomasthorntoncloud"
   | where PodRestartCount > 0
   | summarize max(PodRestartCount) by PodName, ContainerName
   | order by max_PodRestartCount desc
   ```

   **Node CPU utilization over time:**
   ```kql
   Perf
   | where TimeGenerated > ago(1h)
   | where ObjectName == "K8SNode"
   | where CounterName == "cpuUsageNanoCores"
   | summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
   | render timechart
   ```

   **Find OOMKilled containers:**
   ```kql
   KubePodInventory
   | where TimeGenerated > ago(24h)
   | where ContainerStatusReason == "OOMKilled"
   | project TimeGenerated, PodName, ContainerName, ContainerStatusReason
   | order by TimeGenerated desc
   ```

---

### Step 6: Create a Log-Based Alert

Alert when your application logs contain `ERROR` messages.

1. **🔔 Create alert from Log Analytics**

   In Log Analytics → **Logs** → paste this query:

   ```kql
   ContainerLogV2
   | where TimeGenerated > ago(5m)
   | where PodNamespace == "thomasthorntoncloud"
   | where ContainerName contains "devopsjourney"
   | where LogMessage contains "ERROR"
   | count
   ```

2. **➕ Click New alert rule**

   | Setting | Value |
   |---------|-------|
   | **Condition** | Greater than `0` |
   | **Frequency** | Every `5 minutes` |
   | **Severity** | Sev 2 — Warning |
   | **Action** | Email notification via Action Group |

3. **💾 Save the alert rule**

---

## ✅ Validation

**Container Insights checklist:**
- Cluster tab shows CPU, memory, node count, and pod count charts with data
- Containers tab shows pods in `thomasthorntoncloud` namespace
- Nodes tab shows all nodes in Ready state

**Technical validation:**
```bash
# Verify Container Insights add-on is running
kubectl get pods -n kube-system | grep -i "omsagent\|ama-"
# Expected: 1-2 omsagent or ama-logs pods in Running state

# Verify all nodes are Ready
kubectl get nodes
# Expected: All nodes STATUS = Ready

# Verify Flask app pods are Running in the correct namespace
kubectl get pods -n thomasthorntoncloud
# Expected: pods with STATUS = Running

# Check pod resource usage (requires metrics-server)
kubectl top pods -n thomasthorntoncloud
kubectl top nodes
```

**✅ Expected Output:**
```
NAME                    STATUS   ROLES    AGE   VERSION
aks-nodepool1-...       Ready    <none>   5d    v1.33.x

NAME                                    READY   STATUS    RESTARTS   AGE
devopsjourney-app-<hash>                1/1     Running   0          2d
```

---

<details>
<summary>🔧 <strong>Troubleshooting</strong> (click to expand)</summary>

**Common issues:**

```bash
# Problem: Container Insights shows no data / "No data for selected time range"
# Solution 1: Check the OMS Agent / AMA add-on pods
kubectl get pods -n kube-system | grep -E "omsagent|ama-logs"
# Expected: Running pods; if not, the add-on may not be enabled

# Solution 2: Verify the AKS cluster has Container Insights enabled
az aks show --resource-group devopsjourneyapr2026 \
  --name devopsjourneyapr2026aks \
  --query "addonProfiles.omsAgent" -o json
# Expected: { "enabled": true, "config": { "logAnalyticsWorkspaceResourceID": "..." } }

# Problem: KQL query returns no results for ContainerLogV2
# Solution: Older clusters use ContainerLog (V1); try this table name instead
# ContainerLogV2 is the default for clusters created/upgraded after Dec 2022

# Problem: KubePodInventory table is empty
# Solution: Check if diagnostic settings are enabled on the AKS cluster
az monitor diagnostic-settings list \
  --resource $(az aks show -g devopsjourneyapr2026 -n devopsjourneyapr2026aks --query id -o tsv) \
  -o table

# Problem: Pod shows high memory but application seems normal
# Solution: Check if memory limit is set in the Kubernetes manifest
kubectl describe pod -n thomasthorntoncloud <pod-name> | grep -A5 "Limits\|Requests"
```

</details>
```

---

## � Key Takeaways

1. **Container Insights is for infrastructure; Application Insights is for application code** — together they give you the full picture. Container Insights shows CPU/memory/pod health; Application Insights shows HTTP traces, exceptions, and user behaviour. The shared Log Analytics workspace lets you join both datasets in a single KQL query.
2. **`KubePodInventory` is historical** — `kubectl get pods` only shows current state. If a pod crashed and restarted hours ago, `kubectl` shows Running; `KubePodInventory` shows the full lifecycle including crash timestamps and `ContainerStatusReason`. Essential for post-incident analysis.
3. **`OOMKilled` means the container exceeded its memory limit** and was forcibly terminated by the OS. Fix by increasing the memory limit in the deployment manifest, profiling the app for leaks, or scaling horizontally.
4. **Sharing a Log Analytics workspace** enables cross-resource KQL queries — you can correlate application errors (from Application Insights: `requests`/`exceptions`) with pod crashes (from Container Insights: `KubePodInventory`) in a single query. This is a key advantage of workspace-based Application Insights over classic.

---

## ➡️ What's Next

Congratulations 🎉 — you've completed the full DevOps Journey Using Azure DevOps lab series!

You now have a production-grade pipeline that provisions infrastructure with Terraform, builds and pushes container images to ACR, deploys to AKS with zero-touch CI/CD, and monitors everything with Application Insights and Container Insights.

**Lab series summary:**

1. Set up Azure DevOps with Workload Identity Federation
2. Provisioned AKS infrastructure with Terraform
3. Created AD admin group for AKS RBAC
4. Built and pushed the Flask app to ACR
5. Configured Key Vault with App Insights connection string
6. Deployed the app to AKS with the full pipeline
7. Implemented CI/CD with branch triggers
8. Monitored the app with Application Insights
9. Configured availability tests
10. Analysed container metrics with Container Insights and KQL

**[← Back to Lab 6.2](./2-Application-Insights-Configure-Availability-Test.md)** | **[Return to Course Home →](../../README.md)**

---

## 📚 Additional Resources

- 🔗 [Container Insights overview](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview)
- 🔗 [Container Insights — Query container logs](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-log-query)
- 🔗 [KQL quick reference](https://learn.microsoft.com/en-us/azure/data-explorer/kql-quick-reference)
- 🔗 [Azure Monitor for containers](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-analyze)