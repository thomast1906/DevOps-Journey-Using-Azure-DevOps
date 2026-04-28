[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)&ensp;
[![Blog](https://img.shields.io/badge/Blog-thomasthornton.cloud-blue?style=flat-square&logo=hashnode)](https://thomasthornton.cloud/)&ensp;
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Thomas_Thornton-0077b5?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/thomas-thornton-21a86b75/)&ensp;
[![X / Twitter](https://img.shields.io/badge/X-tamstar1234-000000?style=flat-square&logo=x)](https://twitter.com/tamstar1234)

🎯 [What You'll Learn](#-what-youll-learn) &ensp; ✅ [Prerequisites](#-prerequisites) &ensp; 🗺️ [Lab Sequence](#-lab-sequence) &ensp; 🔄 [CI/CD Flow](#-cicd-flow) &ensp; 🙋 [Getting Help](#-getting-help)

# DevOps Journey Using Azure DevOps

> **✨ A hands-on, end-to-end DevOps course — from zero pipeline to a fully monitored AKS application.**

This course walks you through a real-world DevOps setup using Azure DevOps, Terraform, AKS, and Application Insights. Every lab builds on the last, so by the end you'll have a production-style CI/CD pipeline deploying a containerised Python app to Kubernetes — with monitoring and alerting configured.

**No prior Azure DevOps experience required.** If you're comfortable with the Azure portal and a terminal, you're ready.

This course is designed for:

- **Cloud engineers** who want hands-on Azure DevOps and AKS experience
- **Developers** looking to understand infrastructure-as-code with Terraform
- **Teams** wanting a reference implementation for CI/CD on Azure

---

## 🎯 What You'll Learn

| Topic | Skills Gained |
|-------|--------------|
| 🛠️ **Azure DevOps** | Organisations, projects, pipelines-as-code, Workload Identity Federation |
| 🏗️ **Terraform on Azure** | Remote state, modules, AKS, ACR, VNet, Key Vault, Application Insights |
| 🐳 **Containers & ACR** | Docker builds, pushing images, service connections |
| 🚀 **AKS Deployment** | Helm, ALB Controller, Gateway API, kubelogin |
| 🔄 **CI/CD** | Trigger configuration, automated rollouts, rollout status gating |
| 📊 **Monitoring** | Application Insights, availability tests, Log Analytics Container Insights |

---

## ✅ Prerequisites

Before starting, review the full [prerequisites guide](./prerequisites.md). You'll need:

- **Azure subscription** with Contributor access
- **Azure DevOps organisation** — [create one free](https://dev.azure.com/)
- **Azure CLI** — `az` installed and authenticated
- **Terraform** — v1.14+
- **Docker Desktop** — for local image testing
- **kubectl** and **kubelogin**
- **Helm** — v3+

---

## 📚 Lab Sequence

Complete the labs in order — each builds on the previous.

| Lab | Title | What You'll Do |
|:---:|-------|----------------|
| 1a | 🔧 [Azure DevOps Setup](./labs/1-Initial-Setup/1-Azure-DevOps-Setup.md) | Create org, project, and WIF service connection |
| 1b | 🗄️ [Terraform Remote State](./labs/1-Initial-Setup/2-Azure-Terraform-Remote-Storage.md) | Create Azure Storage for Terraform state |
| 1c | 👥 [AKS Admin AD Group](./labs/1-Initial-Setup/3-Create-Azure-AD-AKS-Admins.md) | Create Azure AD group for AKS administrators |
| 2  | ⚙️ [Terraform Pipeline](./labs/2-AzureDevOps-Terraform-Pipeline/1-Setup-AzureDevOps-Pipeline.md) | Deploy all Azure infrastructure via pipeline |
| 3  | 📦 [Deploy App to ACR](./labs/3-Deploy-App-to-ACR/1-Deploy-App-to-ACR.md) | Build and push Docker image to Azure Container Registry |
| 4a | 🔑 [Key Vault Secret](./labs/4-Deploy-App-AKS/1-Update-AD-Group-and-Add-KeyVault-Secret.md) | Store App Insights connection string in Key Vault |
| 4b | 🚀 [Deploy App to AKS](./labs/4-Deploy-App-AKS/2-Update-Pipeline-Deploy-App-AKS.md) | Deploy the containerised app to AKS |
| 5a | 🔄 [Introduce CI/CD](./labs/5-CICD/1-Introduce-CI-CD-to-your-Pipeline.md) | Add pipeline triggers for automatic runs on push |
| 5b | 🤖 [Automated Deployments](./labs/5-CICD/2-Automated-Deployment-AKS-Application.md) | Fully automated deploy on every merge to main |
| 6a | 📊 [Application Insights](./labs/6-Monitoring-and-Alerting/1-Application-Insights.md) | View live telemetry from your running app |
| 6b | 🔔 [Availability Tests](./labs/6-Monitoring-and-Alerting/2-Application-Insights-Configure-Availability-Test.md) | Configure uptime alerting |
| 6c | 📋 [Container Insights](./labs/6-Monitoring-and-Alerting/3-Log-Analytics-Container-Insights.md) | Review AKS logs and metrics in Log Analytics |

---

## 📖 How Each Lab Works

Every lab follows the same pattern:

1. **Context** — why this step matters in a real DevOps workflow
2. **Step-by-step instructions** — exact commands and portal steps
3. **Expected output** — what success looks like
4. **Validation** — how to confirm the step worked before moving on

---

## 🔄 CI/CD Flow

Once all labs are complete, your pipeline works like this:

```
Developer pushes to main
        ↓
Azure DevOps CI triggers
        ↓
Terraform plan → apply  (infrastructure updated)
        ↓
Docker build → push to ACR  (new image tagged with Build ID)
        ↓
kubectl apply to AKS  (rolling update)
        ↓
kubectl rollout status  (pipeline waits for healthy pods)
        ↓
Application Insights + Container Insights  (monitoring active)
```

---

## 🏗️ Infrastructure Overview

All Azure resources are provisioned by Terraform in Lab 2:

| Resource | Name | Purpose |
|----------|------|---------|
| Resource Group | `devopsjourneyoct2024-rg` | Container for all resources |
| AKS Cluster | `devopsjourneyoct2024` | Kubernetes cluster |
| Azure Container Registry | `devopsjourneyoct2024acr` | Docker image registry |
| Key Vault | (from Terraform output) | Secrets management |
| Application Insights | (from Terraform output) | App telemetry |
| Log Analytics Workspace | (from Terraform output) | Centralised logging |
| ALB (App Gateway for Containers) | `devopsjourneyoct2024-alb` | Ingress / load balancing |

---

## 🙋 Getting Help

- 🐛 **Found a bug or issue?** [Open an Issue](https://github.com/thomast1906/DevOps-Journey-Using-Azure-DevOps/issues)
- 🤝 **Want to contribute?** PRs are welcome!
- 📝 **Blog posts and deeper dives:** [thomasthornton.cloud](https://thomasthornton.cloud/)
- 💬 **Connect:** [LinkedIn](https://www.linkedin.com/in/thomas-thornton-21a86b75/) · [X / Twitter](https://twitter.com/tamstar1234)

---

Did you find this helpful? Please ⭐ star and share the repository!

## License

This project is licensed under the terms of the MIT open source license. Please refer to the [LICENSE](./LICENSE) file for the full terms.

