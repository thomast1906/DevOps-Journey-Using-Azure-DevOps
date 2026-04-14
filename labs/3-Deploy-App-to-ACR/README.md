# Deploy Sample Application to Container Registry

## 🚀 Lab Objective
Build the Python/Flask application as a Docker image and push it to Azure Container Registry (ACR).

### Lab Overview
You will:
- Test the Docker image locally (optional but recommended)
- Create an ACR service connection in Azure DevOps using **Workload Identity Federation**
- Update the lab3 pipeline YAML with your ACR details
- Run the pipeline to build and push the Docker image to ACR

### Application Stack
| Component | Details |
|---|---|
| Language | Python 3.13 (Flask 3.1.3) |
| Base Image | `python:3.13-slim` |
| Port | `5000` |
| Telemetry | `azure-monitor-opentelemetry` (OpenTelemetry-based, auto-instruments HTTP requests) |

### Lab Steps
1. [Deploy App to ACR](1-Deploy-App-to-ACR.md) — Build pipeline, ACR push, pipeline configuration
2. [Test Docker Image Locally](docker-image-locally.md) — Optional local build/run steps
