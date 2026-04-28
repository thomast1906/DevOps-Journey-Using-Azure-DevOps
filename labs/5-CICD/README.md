# Introducing CI/CD to Your Pipeline

## 🚀 Lab Objective
Implement Continuous Integration and Continuous Deployment (CI/CD) so every merge to `main` automatically builds, pushes, and deploys the Python/Flask application to AKS.

### Lab Overview
You will:
- Update the pipeline trigger from `trigger: none` to branch-based auto-trigger on `main`
- Switch the Docker image tag from a specific `$(Build.BuildId)` to `latest` with `imagePullPolicy: Always` for zero-downtime rolling updates
- Verify that merging a change automatically kicks off the full build → push → deploy pipeline

### CI/CD Flow
```
Code push to main
  → Azure DevOps pipeline triggers automatically
    → Build & push Docker image (tagged: latest) to ACR
      → Deploy to AKS (imagePullPolicy: Always ensures new image is pulled)
        → Application Insights captures telemetry
```

### Lab Steps
1. [Introduce CI/CD Pipeline Triggers](1-Introduce-CI-CD-to-your-Pipeline.md) — Update trigger configuration
2. [Automated AKS Deployment](2-Automated-Deployment-AKS-Application.md) — Switch to `latest` tag and `imagePullPolicy: Always`
