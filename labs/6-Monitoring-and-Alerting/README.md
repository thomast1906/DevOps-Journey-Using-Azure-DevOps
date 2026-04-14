# Monitoring and Alerting

## 🚀 Lab Objective
Explore the observability tools built into your deployment — Application Insights telemetry from the Python/Flask app, Log Analytics, and Container Insights for the AKS cluster.

### Lab Overview
You will:
- Review live metrics, request traces, and failures in **Application Insights** (powered by `azure-monitor-opentelemetry` SDK)
- Configure an **Availability test** to ping your application endpoint on a schedule
- Explore **Log Analytics** and **Container Insights** for AKS cluster-level observability (node CPU/memory, pod logs)
- Set up **smart detection and custom alerts** based on metric thresholds

### Observability Stack
| Tool | What it monitors |
|---|---|
| Application Insights | HTTP requests, dependencies, exceptions, custom telemetry from the Flask app |
| Log Analytics Workspace | Centralised log store; App Insights and AKS both write here |
| Container Insights | AKS node/pod CPU, memory, and log streaming |
| Availability Tests | Synthetic endpoint monitoring with alerting |

> 💡 The app uses the OpenTelemetry-based `azure-monitor-opentelemetry` SDK — all Flask HTTP requests are auto-instrumented, no manual tracking code required.

### Lab Steps
1. [Application Insights Overview](1-Application-Insights.md) — Live metrics, transaction search, application map, alerts
2. [Configure Availability Test](2-Application-Insights-Configure-Availability-Test.md) — Synthetic ping tests with alert rules
3. [Log Analytics & Container Insights](3-Log-Analytics-Container-Insights.md) — KQL queries, pod logs, node metrics
