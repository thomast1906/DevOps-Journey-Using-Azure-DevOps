# 🔔 Configure Application Insights Availability Tests

> **Estimated Time:** ⏱️ **15-20 minutes**

## 🎯 **Learning Objectives**

By the end of this lab, you will:
- [ ] **Understand availability test types** — URL Ping, Standard, Multi-Step, and Custom TrackAvailability
- [ ] **Configure a classic URL Ping test** — to monitor your application's external availability from multiple regions
- [ ] **Interpret availability test results** — response times, failure locations, and test history
- [ ] **Set up availability alerts** — to be notified when the application becomes unreachable

## 📋 **Prerequisites**

**✅ Required Knowledge:**
- [ ] Application Insights basics (Lab 6.1)
- [ ] Understanding of HTTP endpoints

**🔧 Required Tools:**
- [ ] Azure Portal access

**🏗️ Infrastructure Dependencies:**
- [ ] Completed [Lab 6.1 — Application Insights](./1-Application-Insights.md)
- [ ] Application accessible via public FQDN from Lab 4 (Azure Application Gateway for Containers)

---

## 🏗️ **Availability Test Types**

Application Insights supports four availability test types:

| Type | Best For | Complexity |
|------|----------|-----------|
| **URL Ping (Classic)** | Simple HTTP endpoint check | ⭐ Low |
| **Standard Test** | SSL expiry check + custom headers + HTTP verbs | ⭐⭐ Medium |
| **Multi-Step Web Test** | Complex user journey simulation | ⭐⭐⭐ High |
| **Custom TrackAvailability** | Fully custom test logic via SDK | ⭐⭐⭐⭐ Expert |

This lab uses the **URL Ping (Classic)** test — the simplest and most common starting point for availability monitoring.

---

## 🚀 **Step-by-Step Implementation**

### **Step 1: Get the Application FQDN** ⏱️ *2 minutes*

1. **🌐 Retrieve the ALB FQDN**

   ```bash
   fqdn=$(kubectl get gateway gateway-01 \
     -n thomasthorntoncloud \
     -o jsonpath='{.status.addresses[0].value}')
   echo "Application URL: http://$fqdn"
   ```

   **✅ Expected Output:**
   ```
   Application URL: http://hgduczcae6bad4g5.fz82.alb.azure.com
   ```

   > ⚠️ Availability tests require a **publicly accessible** URL. The Azure Application Gateway for Containers FQDN is public — use this as the test URL.

---

### **Step 2: Create a Classic URL Ping Test** ⏱️ *5 minutes*

1. **🔔 Navigate to Availability**

   Azure Portal → Application Insights (`devopsjourneyoct2024ai`) → **Availability** (left pane).

2. **➕ Add Classic Test**

   Click **Add Classic Test**.

3. **🔧 Configure the test**

   | Setting | Value |
   |---------|-------|
   | **Test name** | `DevOps Journey App - Homepage` |
   | **URL** | `http://<your-fqdn>` (from Step 1) |
   | **Test frequency** | `5 minutes` |
   | **Test locations** | Select 5 locations (e.g., UK South, West Europe, East US, South East Asia, Australia East) |
   | **Success criteria — HTTP status code** | `200` |
   | **Content match (optional)** | `DevOps Journey` (a string expected in the response body) |
   | **Alert on test failures** | Enabled — `2 of 5` locations fail |

   ![](images/monitoring-and-alerting-7.PNG)

4. **💾 Click Create**

   The test begins running from all selected locations within 2-3 minutes.

---

### **Step 3: Configure an Availability Alert** ⏱️ *5 minutes*

1. **🔔 Set up email notifications**

   After creating the test, click the test name → **Alert rules** → **Edit**.

   Configure:
   - **Aggregation**: Count of locations failed
   - **Operator**: Greater than or equal to
   - **Threshold**: `2` (out of 5 locations)
   - **Frequency**: Every `5 minutes`
   - **Action group**: Create one with your email address

2. **💾 Save the alert rule**

   Now if 2 or more test locations report failure, you will receive an email alert within 5-10 minutes.

---

### **Step 4: View Test Results** ⏱️ *5 minutes*

After 10-15 minutes, the test has enough data to display meaningful charts.

1. **📊 Navigate to Availability**

   Application Insights → **Availability**.

2. **🔍 Review the scatter chart**

   Each dot represents a test result:
   - **Green dot** — successful response within SLA
   - **Red dot** — failed response (non-200 or timeout)
   - **Y-axis** — response time in milliseconds
   - **X-axis** — time
   - **Columns** = test locations

   ![](images/monitoring-and-alerting-8.PNG)

3. **📋 Click any dot** to see the request/response details:
   - Request headers sent
   - Response code received
   - Response time
   - Test location that ran the test

---

## ✅ **Validation Steps**

**🔍 Availability Test Validation:**
- [ ] Test appears in the Availability tests list
- [ ] Test shows green results from all 5 locations
- [ ] Response time < 2000ms from all locations
- [ ] Alert rule created and action group configured

**🔧 Technical Validation:**
```bash
# Verify the application is publicly accessible (simulating what the test does)
fqdn=$(kubectl get gateway gateway-01 \
  -n thomasthorntoncloud \
  -o jsonpath='{.status.addresses[0].value}')

# Test from multiple simulated locations using different DNS paths
curl -s -o /dev/null -w "Status: %{http_code} | Time: %{time_total}s\n" "http://$fqdn"

# Generate consistent traffic to populate availability charts
for i in {1..30}; do
  curl -s -o /dev/null "http://$fqdn"
  sleep 5
done
echo "✅ 30 requests sent over 2.5 minutes — check Availability blade"
```

**✅ Expected Output:**
```
Status: 200 | Time: 0.145s
✅ 30 requests sent over 2.5 minutes — check Availability blade
```

---

## 🚨 **Troubleshooting Guide**

**❌ Common Issues:**

```bash
# Problem: Availability test shows all failures (red dots)
# Solution 1: Verify the FQDN is publicly accessible
curl -v "http://<your-fqdn>"
# Expected: HTTP/1.1 200 OK

# Solution 2: If using HTTPS, ensure SSL certificate is valid
curl -v "https://<your-fqdn>" 2>&1 | grep "SSL certificate"

# Problem: Test shows "Cannot parse response" as failure
# Solution: Ensure the "Content match" string exactly matches text in the response body
curl "http://<your-fqdn>" | grep -i "DevOps Journey"

# Problem: Availability alerts fire too frequently (noise)
# Solution: Increase the threshold — require 3/5 locations to fail rather than 2/5
# Or increase test frequency to 15 minutes to reduce alert sensitivity

# Problem: High response times from Asia Pacific locations
# Solution: This is expected for UK-hosted apps due to geography
# Consider deploying to additional Azure regions to improve global latency
```

---

## 💡 **Knowledge Check**

**🎯 Questions:**
1. Why does the availability test require the URL to be publicly accessible?
2. What is the benefit of testing from **multiple geographic locations** simultaneously?
3. When would you use a **Standard Test** instead of a URL Ping Test?
4. What does it mean when a test shows `2/5 locations failed`?

**📝 Answers:**
1. **App Insights availability tests run from Azure infrastructure** — the test agents are hosted in Azure regions around the world and make real HTTP requests to your endpoint from the public internet. Internal-only URLs (private IP, VPN-required) cannot be reached by these test agents. For internal endpoints, use the **Custom TrackAvailability** method from inside your network.
2. **Geographic distribution reveals regional issues** — a CDN misconfiguration, DNS propagation issue, or regional Azure outage may affect some locations but not others. Testing from 5 locations means you get early warning of regional problems before your global users notice them.
3. **Standard Test** is better when you need: (a) SSL certificate expiry warnings (alerts 30/14/7 days before expiry), (b) custom HTTP request headers (e.g., API keys for a secured endpoint), (c) specific HTTP verbs (POST instead of GET), or (d) `Content-Type` matching. URL Ping only does simple GET requests with basic success criteria.
4. **`2/5 locations failed`** means the test ran from 5 geographic locations and 2 of them received a non-200 response or a timeout. The alert threshold of `2/5` reduces false positives — a single transient failure from one location is common noise; consistent failures from multiple locations indicate a real outage.

---

## 🎯 **Next Steps**

**✅ Upon Completion:**
- [ ] Classic URL Ping availability test created
- [ ] Test runs every 5 minutes from 5 geographic locations
- [ ] Availability alert configured with email notification
- [ ] Test results visible in Availability blade (green dots)

**➡️ Continue to:** [Lab 6.3 — Log Analytics & Container Insights](./3-Log-Analytics-Container-Insights.md)

---

## 📚 **Additional Resources**

- 🔗 [Application Insights — Availability overview](https://learn.microsoft.com/en-us/azure/azure-monitor/app/availability-overview)
- 🔗 [Application Insights — URL Ping test](https://learn.microsoft.com/en-us/azure/azure-monitor/app/monitor-web-app-availability)
- 🔗 [Application Insights — Standard test](https://learn.microsoft.com/en-us/azure/azure-monitor/app/availability-standard-tests)
- 🔗 [Application Insights — Custom TrackAvailability](https://learn.microsoft.com/en-us/azure/azure-monitor/app/availability-azure-functions)
