# 📊 Monitor with Application Insights


## 🎯 **Learning Objectives**

By the end of this lab, you will:
- [ ] **Understand what Application Insights collects** — requests, exceptions, dependencies, custom metrics, and usage
- [ ] **Use Live Metrics** — to monitor real-time request rates and failures during a deployment
- [ ] **Use Transaction Search** — to inspect individual HTTP requests and exceptions
- [ ] **Use Failures blade** — to diagnose HTTP errors and exceptions at a glance
- [ ] **Use Application Map** — to visualise dependencies and performance bottlenecks
- [ ] **Configure Smart Detection and Alerts** — to be notified of anomalies automatically

## 📋 **Prerequisites**

**✅ Required Knowledge:**
- [ ] Basic understanding of application telemetry concepts
- [ ] Familiarity with the Azure Portal

**🔧 Required Tools:**
- [ ] Azure Portal access
- [ ] Application deployed to AKS (Labs 4–5)

**🏗️ Infrastructure Dependencies:**
- [ ] Completed [Lab 5 — CI/CD](../5-CICD/2-Automated-Deployment-AKS-Application.md)
- [ ] Application Insights resource provisioned (workspace-based, created by Terraform in Lab 2)
- [ ] `APPLICATIONINSIGHTS_CONNECTION_STRING` injected into the running pods (Lab 4)

---

## 🏗️ **How Application Insights Works in This Lab**

The Python/Flask application uses `azure-monitor-opentelemetry==1.8.7`:

```python
# app.py
from azure.monitor.opentelemetry import configure_azure_monitor
configure_azure_monitor()  # reads APPLICATIONINSIGHTS_CONNECTION_STRING automatically
```

Telemetry flows:
```
Flask App (pod)
  → OpenTelemetry SDK
    → Azure Monitor Exporter
      → App Insights Ingestion Endpoint (from connection string)
        → Log Analytics Workspace (workspace-based)
          → Application Insights blades in Azure Portal
```

> ⚠️ Always use the **Connection String** (not the Instrumentation Key) with `azure-monitor-opentelemetry`. The connection string is stored as the `AIKEY` secret in Key Vault and injected as `APPLICATIONINSIGHTS_CONNECTION_STRING`.

---

## 🚀 **Step-by-Step Implementation**

### **Step 1: Navigate to Application Insights**

1. **🌐 Open the Azure Portal**

   Go to [portal.azure.com](https://portal.azure.com) → search for **Application Insights** → select `devopsjourneyoct2024ai`.

2. **📋 Verify connection string**

   On the **Overview** page, locate the **Connection String** field. This is the value stored in Key Vault as `AIKEY` and injected into your pods.

   ```bash
   # Generate some test traffic first
   fqdn=$(kubectl get gateway gateway-01 -n thomasthorntoncloud \
     -o jsonpath='{.status.addresses[0].value}')
   for i in {1..20}; do curl -s http://$fqdn > /dev/null; done
   echo "✅ 20 test requests sent — wait 1-2 minutes for data to appear in App Insights"
   ```

---

### **Step 2: Live Metrics**

Live Metrics provides near-real-time (< 1 second latency) visibility into your application's performance.

1. **📊 Open Live Metrics**

   In Application Insights → left pane → **Live Metrics**.

2. **🔍 What to look for:**
   - **Incoming Requests/sec** — current request throughput
   - **Failed Requests/sec** — any 4xx/5xx errors
   - **Server Response Time** — p50/p95/p99 latency
   - **Connected Servers** — how many pods are reporting (should match your replica count)

   ![](images/monitoring-and-alerting-1.PNG)

   > 💡 Use Live Metrics during a deployment (`kubectl apply`) to watch requests seamlessly roll over from old pods to new pods.

---

### **Step 3: Transaction Search**

Transaction Search lets you find and drill into individual telemetry events.

1. **🔍 Open Transaction Search**

   Application Insights → **Transaction search** (or **Search**).

2. **🔎 Filter by event type:**
   - **Request** — individual HTTP requests with URL, status code, and duration
   - **Exception** — caught/uncaught Python exceptions with stack traces
   - **Dependency** — outbound calls (e.g., HTTP to external APIs)
   - **Trace** — custom log messages from `logging` module

3. **📋 Find a specific request:**

   ```
   Event type: Request
   Time range: Last 30 minutes
   Search: "GET /"
   ```

   ![](images/monitoring-and-alerting-2.PNG)

   **✅ Expected:**
   - HTTP 200 requests to `/` with duration < 500ms
   - Operation ID for end-to-end tracing

---

### **Step 4: Failures Blade**

The Failures blade shows a consolidated view of all HTTP errors and exceptions, making triage fast.

1. **❌ Open Failures**

   Application Insights → **Failures**.

2. **🔍 Key sections:**
   - **Operations tab** — failed HTTP requests grouped by URL and status code
   - **Exceptions tab** — Python exceptions grouped by exception type
   - **Suggested steps** — AI-powered recommended diagnostics

   ![](images/monitoring-and-alerting-3.PNG)

3. **📋 Click any failure** to see the End-to-End Transaction, including the exact line of Python code that threw the exception.

---

### **Step 5: Application Map**

The Application Map shows all components (services, databases, external APIs) and the call volume and error rate between them.

1. **🗺️ Open Application Map**

   Application Insights → **Application map**.

2. **🔍 What to review:**
   - Each circle = a component (your Flask app, any external dependencies)
   - Arrow thickness = call volume
   - Red = component with failures
   - Click any component for its performance metrics and failures

   ![](images/monitoring-and-alerting-4.PNG)

   > 💡 If your app calls an external API or database, those dependencies appear automatically when the SDK intercepts the outbound calls.

---

### **Step 6: Smart Detection and Alerts**

Application Insights automatically learns your application's baseline and alerts you when anomalies occur.

1. **🔔 Review Smart Detection**

   Application Insights → **Smart detection** (or **Alerts** → **Smart detector alert rules**).

   Smart Detection automatically monitors for:
   - Abnormal rise in failed request rate
   - Abnormal rise in server response time
   - Degradation in server response time
   - Memory leak pattern

   ![](images/monitoring-and-alerting-5.PNG)

2. **➕ Create a custom alert**

   Application Insights → **Alerts** → **+ New alert rule**:

   | Setting | Value |
   |---------|-------|
   | Signal | `Failed requests` (metric) |
   | Operator | Greater than |
   | Threshold | `5` (requests in 5 minutes) |
   | Severity | `Sev 2 — Warning` |
   | Action | Email notification |

---

### **Step 7: Usage Analysis**

Usage analysis helps you understand how users interact with your application.

1. **📈 Open Usage**

   Application Insights → **Usage** section → **Users**, **Sessions**, or **Retention**.

   ![](images/monitoring-and-alerting-6.PNG)

2. **🔍 What to review:**
   - **Users** — unique visitors per day
   - **Sessions** — session duration and depth
   - **Retention** — percentage of users who return after first visit

---

## ✅ **Validation Steps**

**🔍 Telemetry Validation:**
- [ ] Application Insights receives data (requests visible in Transaction Search)
- [ ] Live Metrics shows connected server count matching AKS replica count
- [ ] No unexpected exceptions in Failures blade

**🔧 Technical Validation:**
```bash
# Generate test traffic
fqdn=$(kubectl get gateway gateway-01 -n thomasthorntoncloud \
  -o jsonpath='{.status.addresses[0].value}')
for i in {1..10}; do curl -s "http://$fqdn" > /dev/null; sleep 1; done

# Verify APPLICATIONINSIGHTS_CONNECTION_STRING is set in the pod
POD=$(kubectl get pods -n thomasthorntoncloud -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$POD" -n thomasthorntoncloud -- \
  env | grep APPLICATIONINSIGHTS_CONNECTION_STRING

# Verify connection string starts with InstrumentationKey=
kubectl exec "$POD" -n thomasthorntoncloud -- \
  env | grep "APPLICATIONINSIGHTS_CONNECTION_STRING" | grep -c "InstrumentationKey=" \
  && echo "✅ Connection string format valid"
```

**✅ Expected Output:**
```
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=...;IngestionEndpoint=...;LiveEndpoint=...
✅ Connection string format valid
```

---

## 🚨 **Troubleshooting Guide**

**❌ Common Issues:**

```bash
# Problem: No data appears in Application Insights (Live Metrics shows 0 servers)
# Solution 1: Check APPLICATIONINSIGHTS_CONNECTION_STRING is set in the pod
kubectl exec "$POD" -n thomasthorntoncloud -- env | grep APPLICATIONINSIGHTS

# Solution 2: Check the aikey Kubernetes secret exists and is correctly set
kubectl get secret aikey -n thomasthorntoncloud -o jsonpath='{.data.aisecret}' \
  | base64 --decode | grep "InstrumentationKey="

# Solution 3: Verify the secret value in Key Vault matches what the pod receives
az keyvault secret show --vault-name devopsjourneyoct2024-kv --name AIKEY \
  --query value -o tsv | grep "InstrumentationKey="

# Problem: Connection string using wrong format (just GUID, not full string)
# Solution: The secret should start with "InstrumentationKey=" not just the GUID
# Update Key Vault secret with the full connection string from Azure Portal
az keyvault secret set --vault-name devopsjourneyoct2024-kv --name AIKEY \
  --value "InstrumentationKey=...;IngestionEndpoint=...;LiveEndpoint=..."

# Problem: App Insights data appears with 2-5 minute delay
# Solution: This is normal for the standard ingestion pipeline
# Live Metrics shows near-real-time; other blades have 2-5 min lag
```

---

## 💡 **Knowledge Check**

**🎯 Questions:**
1. Why does this lab use `APPLICATIONINSIGHTS_CONNECTION_STRING` instead of `APPINSIGHTS_INSTRUMENTATIONKEY`?
2. What is the difference between **workspace-based** and **classic** Application Insights?
3. How does the `azure-monitor-opentelemetry` SDK know where to send telemetry?
4. What is the difference between Smart Detection and manual alert rules?

**📝 Answers:**
1. **`azure-monitor-opentelemetry==1.8.7` requires the connection string** — the SDK uses the OpenTelemetry Azure Monitor exporter, which reads `APPLICATIONINSIGHTS_CONNECTION_STRING` to configure the correct regional ingestion endpoint. `APPINSIGHTS_INSTRUMENTATIONKEY` is the legacy env var for the older Application Insights SDK and is not supported by the OpenTelemetry exporter.
2. **Workspace-based** App Insights stores data in a **Log Analytics workspace** — enabling KQL queries, cross-resource queries, longer retention, and integration with Azure Monitor alerts and workbooks. **Classic** App Insights stored data in its own proprietary store. All new deployments should use workspace-based (this lab's Terraform creates workspace-based by default).
3. **The SDK reads `APPLICATIONINSIGHTS_CONNECTION_STRING`** at startup via `configure_azure_monitor()`. The connection string includes the `IngestionEndpoint` URL (e.g., `https://uksouth-1.in.applicationinsights.azure.com/`) and `LiveEndpoint` URL. The SDK configures the OpenTelemetry pipeline to export spans, metrics, and logs to these endpoints.
4. **Smart Detection** automatically learns your app's baseline and alerts on anomalies (no threshold to set); it adapts over time. **Manual alert rules** fire when a metric crosses a fixed threshold you define — predictable but requires you to know the right threshold value. Use Smart Detection as an early warning system and manual alerts for business-critical SLAs.

---

## 🎯 **Next Steps**

**✅ Upon Completion:**
- [ ] Confirmed telemetry is flowing from Flask app → App Insights
- [ ] Reviewed Live Metrics, Transaction Search, Failures, and Application Map
- [ ] Created at least one custom alert

**➡️ Continue to:** [Lab 6.2 — Configure Availability Tests](./2-Application-Insights-Configure-Availability-Test.md)

---

## 📚 **Additional Resources**

- 🔗 [Application Insights overview](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- 🔗 [azure-monitor-opentelemetry — Python SDK](https://learn.microsoft.com/en-us/azure/azure-monitor/app/opentelemetry-enable?tabs=python)
- 🔗 [Application Insights connection strings](https://learn.microsoft.com/en-us/azure/azure-monitor/app/sdk-connection-string)
- 🔗 [Smart Detection in Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/proactive-diagnostics)