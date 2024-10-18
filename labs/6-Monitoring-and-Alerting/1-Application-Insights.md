# Using Application Insights to View Telemetry Data

## 🎯 Purpose
Understand and utilize Application Insights to monitor and analyze your application's performance and user behaviour.

## 1. What is Application Insights?

Application Insights, a feature of Azure Monitor, is an extensible Application Performance Management (APM) service tailored for developers and DevOps professionals. It helps monitor live applications, automatically detects performance anomalies, and includes robust analytics tools to diagnose issues and understand user interactions. Application Insights is designed to continuously enhance your application's performance and usability.

### 🔍 Verification:
1. Confirm you can access your Application Insights resource in the Azure portal

### 🧠 Knowledge Check:
1. How does Application Insights differ from traditional monitoring tools?
2. What types of data can Application Insights collect?

#### 💡 Pro Tip: Integrate Application Insights early in your development process for comprehensive monitoring from the start. 

## 2. Live Metrics
When deploying a new build, monitor near-real-time performance indicators to ensure everything operates as expected.

![](images/monitoring-and-alerting-1.PNG)

### 🔍 Verification:
1. Check that you can see incoming requests and other live metrics

### 🧠 Knowledge Check:
1. How can live metrics help during a deployment?
2. What key metrics should you focus on in real-time?

#### 💡 Pro Tip: Use live metrics to quickly identify and respond to performance issues during critical deployments.

## 3. Transaction search for instance data
Search and filter events such as requests, exceptions, dependency calls, log traces, and page views to examine specific transactions.

![](images/monitoring-and-alerting-2.PNG)

### 🔍 Verification:
1. Successfully filter and find a specific request or exception

### 🧠 Knowledge Check:
1. What types of events can you search for?
2. How can transaction search help in debugging?

#### 💡 Pro Tip: Create saved queries for commonly searched patterns to speed up your diagnostic process.

## 4. Viewing failures easily
Quickly identify and review failures within the Application Insights pane.

![](images/monitoring-and-alerting-3.PNG)

### 🔍 Verification:
1. Locate the failures section and review any recent exceptions

### 🧠 Knowledge Check:
1. How does Application Insights categorize failures?
2. What information is provided for each failure?

#### 💡 Pro Tip: Set up alerts for sudden increases in failure rates to catch issues early. 

## 5. Application map
Explore your application's components, along with key metrics and alerts, through the Application Map.

![](images/monitoring-and-alerting-4.PNG)

### 🔍 Verification:
1. Identify all major components of your application in the map

### 🧠 Knowledge Check:
1. How does the application map help in understanding system architecture?
2. What performance metrics are displayed on the map?

#### 💡 Pro Tip: Use the application map to identify dependencies and potential bottlenecks in your system.

## 6. Smart detection and manual alerts
Set up automatic alerts that adapt to your application's normal telemetry patterns and trigger when anomalies occur. Additionally, you can create alerts based on specific custom or standard metric thresholds.

![](images/monitoring-and-alerting-5.PNG)

### 🔍 Verification:
1. Create a custom alert based on a specific metric

### 🧠 Knowledge Check:
1. How do smart detection alerts differ from manual alerts?
2. What scenarios are best suited for each type of alert?

#### 💡 Pro Tip: Start with broader alerts and refine them over time based on your application's patterns and needs.

## 6. Usage analysis
Analyse user segmentation and retention to understand user behavior and improve user experience.

![](images/monitoring-and-alerting-6.PNG)

### 🔍 Verification:
1. Review user retention data and identify common user paths

### 🧠 Knowledge Check:
1. How can usage analysis inform product decisions?
2. What metrics are most valuable for understanding user behavior?

#### 💡 Pro Tip: Combine usage analysis with A/B testing to make data-driven UX improvements.