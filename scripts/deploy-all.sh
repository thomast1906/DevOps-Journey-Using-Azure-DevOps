#!/bin/bash

# DevOps Journey Using Azure DevOps - Full Local Deployment Script
# This script deploys the entire infrastructure and application locally
# for testing purposes, bypassing Azure DevOps pipelines.
#
# Run from the repository root: ./scripts/deploy-all.sh
#
# Prerequisites: az, terraform, docker, kubectl

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MONITORING_WARNINGS=0

# Non-fatal warning collector for monitoring checks
monitoring_warn() {
    echo -e "${YELLOW}⚠️  [Monitoring] $*${NC}"
    MONITORING_WARNINGS=$((MONITORING_WARNINGS + 1))
}

# Configuration — override with environment variables
PROJECT_NAME="${PROJECT_NAME:-devopsjourneyoct2024}"
LOCATION="${LOCATION:-uksouth}"
TF_RG="devops-journey-rg-oct2024"
TF_SA="${PROJECT_NAME}"
TF_CONTAINER="tfstate"
TF_DIR="$REPO_ROOT/labs/2-AzureDevOps-Terraform-Pipeline/terraform"
APP_DIR="$REPO_ROOT/labs/3-Deploy-App-to-ACR/app"
APP_YAML="$REPO_ROOT/labs/4-Deploy-App-AKS/pipelines/scripts/app.yaml"
ACR_NAME="${PROJECT_NAME}acr"
IMAGE_NAME="thomasthorntoncloud"
IMAGE_TAG="${IMAGE_TAG:-$(git rev-parse --short HEAD 2>/dev/null || date +%Y%m%d%H%M%S)}"

echo -e "${BLUE}🚀 Starting DevOps Journey Using Azure DevOps - Local Deployment${NC}"
echo -e "${BLUE}Project:  ${PROJECT_NAME}${NC}"
echo -e "${BLUE}Location: ${LOCATION}${NC}"
echo ""

print_step() {
    echo -e "${GREEN}📋 Step $1: $2${NC}"
    echo "----------------------------------------"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ── Step 0: Prerequisites ──────────────────────────────────────────────────
print_step "0" "Checking Prerequisites"

for tool in az terraform docker kubectl; do
    if ! command_exists "$tool"; then
        echo -e "${RED}❌ ${tool} not found. Please install it first.${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ All prerequisites met${NC}"
echo ""

# ── Step 1: Azure authentication ───────────────────────────────────────────
print_step "1" "Verifying Azure Authentication"

if ! az account show &>/dev/null; then
    echo -e "${YELLOW}⚠️  Not logged into Azure. Running az login...${NC}"
    az login
fi

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo -e "${GREEN}✅ Logged into Azure (Subscription: ${SUBSCRIPTION_ID})${NC}"
echo ""

# ── Step 2: Terraform remote state storage ─────────────────────────────────
print_step "2" "Creating Terraform Remote State Storage"

STORAGE_SCRIPT="$REPO_ROOT/labs/1-Initial-Setup/scripts/create-terraform-storage.sh"
if [ -f "$STORAGE_SCRIPT" ]; then
    chmod +x "$STORAGE_SCRIPT"
    bash "$STORAGE_SCRIPT"
else
    echo -e "${YELLOW}⚠️  Storage script not found, creating manually...${NC}"
    az group create --name "$TF_RG" --location "$LOCATION" --output none
    az storage account create --name "$TF_SA" --resource-group "$TF_RG" \
        --location "$LOCATION" --sku Standard_LRS --output none
    az storage container create --name "$TF_CONTAINER" --account-name "$TF_SA" --output none
fi

echo -e "${GREEN}✅ Terraform state storage ready${NC}"
echo ""

# ── Step 3: Azure AD Group ─────────────────────────────────────────────────
print_step "3" "Creating Azure AD Group for AKS Admins"

AD_SCRIPT="$REPO_ROOT/labs/1-Initial-Setup/scripts/create-azure-ad-group.sh"
AKS_GROUP_NAME="devopsjourney-aks-group-oct2024"
if [ -f "$AD_SCRIPT" ]; then
    chmod +x "$AD_SCRIPT"
    bash "$AD_SCRIPT"
else
    AKS_GROUP_NAME="AKS-Admins-${PROJECT_NAME}"
    echo -e "${YELLOW}⚠️  AD group script not found, creating group '${AKS_GROUP_NAME}'...${NC}"
    az ad group create \
        --display-name "$AKS_GROUP_NAME" \
        --mail-nickname "aks-admins-${PROJECT_NAME}" \
        --output none
fi

AKS_ADMINS_GROUP_ID=$(az ad group show --group "$AKS_GROUP_NAME" --query id -o tsv)
echo -e "${GREEN}✅ AKS Admins Group ID: ${AKS_ADMINS_GROUP_ID}${NC}"

echo ""

# ── SSH key for AKS nodes ──────────────────────────────────────────────────
SSH_KEY_FILE="$HOME/.ssh/id_rsa_aks"
if [ ! -f "${SSH_KEY_FILE}.pub" ]; then
    echo -e "${YELLOW}🔑 Generating SSH key for AKS nodes...${NC}"
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_FILE" -N "" -q
fi
SSH_PUBLIC_KEY=$(cat "${SSH_KEY_FILE}.pub")
echo -e "${GREEN}✅ SSH public key loaded${NC}"

echo ""

# ── Step 4: Terraform deploy ───────────────────────────────────────────────
print_step "4" "Deploying Infrastructure with Terraform"

cd "$TF_DIR"

echo -e "${YELLOW}📋 Running terraform init...${NC}"
terraform init \
    -backend-config="resource_group_name=${TF_RG}" \
    -backend-config="storage_account_name=${TF_SA}" \
    -backend-config="container_name=${TF_CONTAINER}" \
    -backend-config="key=terraform.tfstate" \
    -reconfigure

echo -e "${YELLOW}📋 Running terraform plan...${NC}"
terraform plan \
    -var-file="../vars/production.tfvars" \
    -var "aks_admins_group_object_id=${AKS_ADMINS_GROUP_ID}" \
    -var "ssh_public_key=${SSH_PUBLIC_KEY}" \
    -out=tfplan

echo -e "${YELLOW}📋 Running terraform apply...${NC}"
terraform apply tfplan
rm -f tfplan

echo -e "${GREEN}✅ Infrastructure deployed${NC}"
echo ""

# ── Step 5: AKS credentials ────────────────────────────────────────────────
print_step "5" "Getting AKS Credentials"

AKS_NAME=$(terraform -chdir="$TF_DIR" output -raw aks_name 2>/dev/null)
if [ -z "$AKS_NAME" ]; then
    AKS_NAME=$(grep 'aks_name' "$REPO_ROOT/labs/2-AzureDevOps-Terraform-Pipeline/vars/production.tfvars" | awk -F'"' '{print $2}')
fi
AKS_RG=$(terraform -chdir="$TF_DIR" output -raw aks_resource_group 2>/dev/null || echo "${PROJECT_NAME}-rg")
echo -e "${YELLOW}📋 Fetching credentials for cluster: ${AKS_NAME}${NC}"

az aks get-credentials \
    --resource-group "${AKS_RG}" \
    --name "$AKS_NAME" \
    --overwrite-existing

echo -e "${GREEN}✅ kubectl configured${NC}"
echo ""

# ── Step 6: Docker build & push ────────────────────────────────────────────
print_step "6" "Building and Pushing Docker Image to ACR"

echo -e "${YELLOW}📋 Logging into ACR: ${ACR_NAME}${NC}"
az acr login --name "$ACR_NAME"

FULL_IMAGE="${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}"

echo -e "${YELLOW}📋 Building Docker image (linux/amd64)...${NC}"
docker build --platform linux/amd64 \
    -t "$FULL_IMAGE" \
    "$APP_DIR"

echo -e "${YELLOW}📋 Pushing image: ${FULL_IMAGE}${NC}"
docker push "$FULL_IMAGE"

echo -e "${GREEN}✅ Image pushed: ${FULL_IMAGE}${NC}"
echo ""

# ── Step 7: Update app.yaml image reference ────────────────────────────────
print_step "7" "Updating Kubernetes Manifest with Image Reference"

sed -i.bak "s|image: .*\.azurecr\.io/.*|image: ${FULL_IMAGE}|g" "$APP_YAML"
rm -f "${APP_YAML}.bak"

echo -e "${GREEN}✅ app.yaml updated with image: ${FULL_IMAGE}${NC}"
echo ""

# ── Step 8: Create App Insights secret in Kubernetes ──────────────────────
print_step "8" "Creating App Insights Secret in Kubernetes (Lab 6)"

KV_NAME="${PROJECT_NAME}-kv"
kubectl create namespace thomasthorntoncloud --dry-run=client -o yaml | kubectl apply -f -

AI_CONN_STR=$(az keyvault secret show --vault-name "$KV_NAME" --name "AIKEY" \
    --query value -o tsv 2>/dev/null || true)
if [ -n "$AI_CONN_STR" ]; then
    kubectl create secret generic aikey \
        --from-literal=aisecret="$AI_CONN_STR" \
        --namespace thomasthorntoncloud \
        --dry-run=client -o yaml | kubectl apply -f -
    echo -e "${GREEN}✅ aikey secret created/updated in thomasthorntoncloud namespace${NC}"
else
    monitoring_warn "AIKEY not found in Key Vault '${KV_NAME}'. App will start but telemetry will not be sent."
    echo -e "${YELLOW}    Fix: az keyvault secret set --vault-name ${KV_NAME} --name AIKEY --value 'InstrumentationKey=...'${NC}"
fi
echo ""

# ── Step 9: Deploy to Kubernetes ───────────────────────────────────────────
print_step "9" "Deploying Application to AKS"

echo -e "${YELLOW}📋 Applying Kubernetes manifest...${NC}"
kubectl apply -f "$APP_YAML"

echo -e "${YELLOW}📋 Waiting for deployment to be ready (up to 5 minutes)...${NC}"
kubectl rollout status deployment/thomasthornton \
    -n thomasthorntoncloud \
    --timeout=300s

echo -e "${GREEN}✅ Application deployed${NC}"
echo ""

# ── Step 10: Get application URL ──────────────────────────────────────────
print_step "10" "Getting Application URL"

APP_URL=""

# Try ALB Gateway API FQDN first (set up by lab4/lab5 pipeline)
GATEWAY_FQDN=$(kubectl get gateway gateway-01 -n thomasthorntoncloud \
    -o jsonpath='{.status.addresses[0].value}' 2>/dev/null || true)
if [ -n "$GATEWAY_FQDN" ]; then
    APP_URL="http://${GATEWAY_FQDN}"
    echo -e "${GREEN}✅ ALB Gateway FQDN: ${APP_URL}${NC}"
fi

# Service is ClusterIP — access is via the ALB Gateway API only
if [ -z "$APP_URL" ]; then
    echo -e "${YELLOW}⚠️  ALB Gateway not yet ready. Once provisioned, get the FQDN with:${NC}"
    echo -e "${YELLOW}    kubectl get gateway gateway-01 -n thomasthorntoncloud -o jsonpath='{.status.addresses[0].value}'${NC}"
fi

if [ -n "$APP_URL" ]; then
    if curl -sf --max-time 10 "$APP_URL" >/dev/null; then
        echo -e "${GREEN}✅ Application is responding at ${APP_URL}${NC}"
    else
        echo -e "${YELLOW}⚠️  Application may still be warming up. Try: ${APP_URL}${NC}"
    fi
else
    monitoring_warn "Application URL not yet available."
    echo -e "${YELLOW}    Check: kubectl get svc thomasthorntoncloud -n thomasthorntoncloud${NC}"
fi
echo ""

# ── Step 11: Verify Application Insights (Lab 6) ──────────────────────────
print_step "11" "Verifying Application Insights Configuration (Lab 6)"

# Check Kubernetes secret
if kubectl get secret aikey -n thomasthorntoncloud &>/dev/null; then
    echo -e "${GREEN}✅ aikey Kubernetes secret exists in thomasthorntoncloud namespace${NC}"
else
    monitoring_warn "aikey Kubernetes secret not found — pods cannot send telemetry to App Insights"
    echo -e "${YELLOW}    Fix: set AIKEY in Key Vault '${KV_NAME}' and re-run Step 8${NC}"
fi

# Verify env var is set in a running pod without printing the secret value
RUNNING_POD=$(kubectl get pods -n thomasthorntoncloud \
    --field-selector=status.phase=Running \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
if [ -n "$RUNNING_POD" ]; then
    if kubectl exec "$RUNNING_POD" -n thomasthorntoncloud -- env 2>/dev/null \
            | grep -q "^APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey="; then
        echo -e "${GREEN}✅ APPLICATIONINSIGHTS_CONNECTION_STRING is set correctly in pod '${RUNNING_POD}'${NC}"
    else
        monitoring_warn "APPLICATIONINSIGHTS_CONNECTION_STRING not found or invalid in pod '${RUNNING_POD}'"
        echo -e "${YELLOW}    Check: kubectl exec ${RUNNING_POD} -n thomasthorntoncloud -- env | grep APPLICATIONINSIGHTS${NC}"
    fi
else
    monitoring_warn "No running pods found in thomasthorntoncloud namespace"
fi
echo ""

# ── Step 12: Verify Container Insights (Lab 6) ────────────────────────────
print_step "12" "Verifying Container Insights (Lab 6)"

# Azure-side check — definitive proof Container Insights is enabled
OMS_STATUS=$(az aks show \
    --resource-group "${PROJECT_NAME}-rg" \
    --name "$AKS_NAME" \
    --query "addonProfiles.omsAgent.enabled" -o tsv 2>/dev/null || true)
if [ "$OMS_STATUS" = "true" ]; then
    echo -e "${GREEN}✅ Container Insights (omsAgent) is enabled on cluster '${AKS_NAME}'${NC}"
else
    monitoring_warn "Container Insights does not appear to be enabled — check Terraform oms_agent block"
fi

# In-cluster agent pod check (ama-logs for newer, omsagent for older clusters)
INSIGHTS_PODS=$(kubectl get pods -n kube-system --no-headers 2>/dev/null \
    | grep -E "ama-logs|omsagent" | grep -c "Running" || true)
if [ "${INSIGHTS_PODS:-0}" -gt 0 ]; then
    echo -e "${GREEN}✅ Container Insights agent pods running: ${INSIGHTS_PODS}${NC}"
else
    monitoring_warn "No ama-logs/omsagent pods running in kube-system"
fi

# Node readiness
NOT_READY=$(kubectl get nodes --no-headers 2>/dev/null \
    | grep -cv " Ready" || echo "unknown")
if [ "$NOT_READY" = "0" ]; then
    echo -e "${GREEN}✅ All AKS nodes are Ready${NC}"
else
    monitoring_warn "${NOT_READY} node(s) not in Ready state"
fi

# kubectl top is best-effort — requires metrics-server, not Container Insights
echo -e "${YELLOW}📋 Pod resource usage (best-effort, requires metrics-server):${NC}"
kubectl top pods -n thomasthorntoncloud 2>/dev/null \
    || echo -e "${YELLOW}  kubectl top unavailable (metrics-server may not be installed)${NC}"
kubectl top nodes 2>/dev/null || true
echo ""

# ── Step 13: Generate test traffic for App Insights telemetry (Lab 6) ─────
print_step "13" "Generating Test Traffic for Telemetry (Lab 6)"

if [ -n "$APP_URL" ]; then
    echo -e "${YELLOW}📋 Sending 20 requests to ${APP_URL} to seed App Insights telemetry...${NC}"
    SUCCESS=0
    for i in $(seq 1 20); do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$APP_URL" 2>/dev/null || echo "000")
        if [ "$STATUS" = "200" ]; then
            SUCCESS=$((SUCCESS + 1))
        fi
        sleep 1
    done
    echo -e "${GREEN}✅ ${SUCCESS}/20 requests returned HTTP 200${NC}"
    if [ "$SUCCESS" -lt 18 ]; then
        monitoring_warn "Only ${SUCCESS}/20 requests succeeded — check pod logs"
        echo -e "${YELLOW}    kubectl logs -n thomasthorntoncloud deployment/thomasthornton${NC}"
    fi
    echo -e "${YELLOW}ℹ️  App Insights has a 2–5 minute ingestion lag — allow time before checking the portal.${NC}"
else
    monitoring_warn "No application URL — skipping traffic generation"
fi
echo ""

# ── Final Summary ──────────────────────────────────────────────────────────
echo -e "${GREEN}🎉 DevOps Journey deployment complete!${NC}"

if [ "${MONITORING_WARNINGS}" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  ${MONITORING_WARNINGS} monitoring warning(s) — see above for details${NC}"
fi

AI_NAME="${PROJECT_NAME}ai"
LA_NAME="${PROJECT_NAME}la"
BASE="https://portal.azure.com/#resource/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${PROJECT_NAME}-rg/providers"

echo ""
echo -e "${BLUE}📊 Monitoring Portal Links (Lab 6):${NC}"
echo "  App Insights:       ${BASE}/microsoft.insights/components/${AI_NAME}/overview"
echo "  Log Analytics:      ${BASE}/Microsoft.OperationalInsights/workspaces/${LA_NAME}/overview"
echo "  Container Insights: ${BASE}/Microsoft.ContainerService/managedClusters/${AKS_NAME}/insights"

echo ""
echo -e "${BLUE}📋 Useful commands:${NC}"
echo "  kubectl get pods -n thomasthorntoncloud"
echo "  kubectl logs -n thomasthorntoncloud deployment/thomasthornton"
echo "  kubectl get svc -n thomasthorntoncloud"
if [ -n "${APP_URL:-}" ]; then
    echo "  curl ${APP_URL}"
fi
echo ""
echo -e "${BLUE}📋 Clean up when done:${NC}"
echo "  ./scripts/cleanup-all.sh"
