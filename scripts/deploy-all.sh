#!/bin/bash

# DevOps Journey Using Azure DevOps - Full Local Deployment Script
# This script deploys the entire infrastructure and application locally
# for testing purposes, bypassing Azure DevOps pipelines.
#
# Run from the repository root: ./scripts/deploy-all.sh
#
# Prerequisites: az, terraform, docker, kubectl

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
IMAGE_TAG="latest"

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
if [ -f "$AD_SCRIPT" ]; then
    chmod +x "$AD_SCRIPT"
    bash "$AD_SCRIPT"
else
    GROUP_NAME="AKS-Admins-${PROJECT_NAME}"
    echo -e "${YELLOW}⚠️  AD group script not found, creating group '${GROUP_NAME}'...${NC}"
    GROUP_ID=$(az ad group create \
        --display-name "$GROUP_NAME" \
        --mail-nickname "aks-admins-${PROJECT_NAME}" \
        --query id -o tsv)
    echo -e "${YELLOW}⚠️  Created AD Group: ${GROUP_ID}${NC}"
    echo -e "${YELLOW}    Update admin_object_id in production.tfvars if needed.${NC}"
fi

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
    -out=tfplan

echo -e "${YELLOW}📋 Running terraform apply...${NC}"
terraform apply tfplan
rm -f tfplan

echo -e "${GREEN}✅ Infrastructure deployed${NC}"
echo ""

# ── Step 5: AKS credentials ────────────────────────────────────────────────
print_step "5" "Getting AKS Credentials"

AKS_NAME=$(terraform -chdir="$TF_DIR" output -raw aks_name 2>/dev/null || echo "${PROJECT_NAME}aks")
echo -e "${YELLOW}📋 Fetching credentials for cluster: ${AKS_NAME}${NC}"

az aks get-credentials \
    --resource-group "${PROJECT_NAME}-rg" \
    --name "$AKS_NAME" \
    --overwrite-existing \
    --admin

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

sed -i.bak "s|image:.*# Update this line|image: ${FULL_IMAGE} # Updated by deploy-all.sh|g" "$APP_YAML"
rm -f "${APP_YAML}.bak"

echo -e "${GREEN}✅ app.yaml updated with image: ${FULL_IMAGE}${NC}"
echo ""

# ── Step 8: Deploy to Kubernetes ───────────────────────────────────────────
print_step "8" "Deploying Application to AKS"

kubectl create namespace thomasthorntoncloud --dry-run=client -o yaml | kubectl apply -f -

echo -e "${YELLOW}📋 Applying Kubernetes manifest...${NC}"
kubectl apply -f "$APP_YAML"

echo -e "${YELLOW}📋 Waiting for deployment to be ready (up to 5 minutes)...${NC}"
kubectl rollout status deployment/thomasthornton \
    -n thomasthorntoncloud \
    --timeout=300s

echo -e "${GREEN}✅ Application deployed${NC}"
echo ""

# ── Step 9: Get application URL ────────────────────────────────────────────
print_step "9" "Getting Application URL"

echo -e "${YELLOW}📋 Waiting for LoadBalancer IP...${NC}"
for i in $(seq 1 12); do
    EXTERNAL_IP=$(kubectl get svc thomasthorntoncloud \
        -n thomasthorntoncloud \
        -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
    if [ -n "$EXTERNAL_IP" ]; then
        break
    fi
    echo -e "${YELLOW}  Waiting... (${i}/12)${NC}"
    sleep 15
done

if [ -n "$EXTERNAL_IP" ]; then
    echo ""
    echo -e "${GREEN}🎉 Deployment Successful!${NC}"
    echo -e "${GREEN}🌐 Application URL: http://${EXTERNAL_IP}${NC}"
    if curl -sf "http://$EXTERNAL_IP" >/dev/null; then
        echo -e "${GREEN}✅ Application is responding correctly!${NC}"
    else
        echo -e "${YELLOW}⚠️  Application may still be warming up. Try: http://${EXTERNAL_IP}${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  LoadBalancer IP not yet assigned. Check with:${NC}"
    echo "    kubectl get svc thomasthorntoncloud -n thomasthorntoncloud"
fi

echo ""
echo -e "${GREEN}🎉 DevOps Journey deployment complete!${NC}"
echo -e "${BLUE}📋 Useful commands:${NC}"
echo "  kubectl get pods -n thomasthorntoncloud"
echo "  kubectl logs -n thomasthorntoncloud deployment/thomasthornton"
echo "  kubectl get svc -n thomasthorntoncloud"
echo ""
echo -e "${BLUE}📋 Clean up when done:${NC}"
echo "  ./scripts/cleanup-all.sh"
