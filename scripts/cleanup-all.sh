#!/bin/bash

# DevOps Journey Using Azure DevOps - Cleanup Script
# Deletes all Azure resources created by deploy-all.sh
#
# Run from the repository root: ./scripts/cleanup-all.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration — must match what was used in deploy-all.sh
PROJECT_NAME="${PROJECT_NAME:-devopsjourneyoct2024}"
RESOURCE_GROUP="${PROJECT_NAME}-rg"
TF_RG="devops-journey-rg-oct2024"

echo -e "${RED}🗑️  DevOps Journey Using Azure DevOps - CLEANUP${NC}"
echo -e "${RED}⚠️  WARNING: This will DELETE ALL resources!${NC}"
echo ""
echo -e "${YELLOW}Resource groups to be deleted:${NC}"
echo -e "${YELLOW}  • ${RESOURCE_GROUP}${NC}"
echo -e "${YELLOW}  • ${PROJECT_NAME}-node-rg (AKS node pool RG)${NC}"
echo ""

read -p "Type 'DELETE' to confirm resource deletion: " confirmation
if [ "$confirmation" != "DELETE" ]; then
    echo -e "${GREEN}✅ Cleanup cancelled${NC}"
    exit 0
fi

echo ""

if ! az account show &>/dev/null; then
    echo -e "${RED}❌ Not logged into Azure. Please run: az login${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Deleting main resource group: ${RESOURCE_GROUP}${NC}"
az group delete --name "$RESOURCE_GROUP" --yes --no-wait 2>/dev/null \
    || echo -e "${YELLOW}⚠️  Resource group not found or already deleted${NC}"

echo -e "${BLUE}ℹ️  Key Vault note: purge protection is enabled (soft-delete retention: 7 days).${NC}"
echo -e "${BLUE}    If you need to re-run the lab with the same project name within 7 days,${NC}"
echo -e "${BLUE}    use a different PROJECT_NAME to avoid name conflicts.${NC}"
echo -e "${BLUE}    After 7 days the soft-deleted vault is automatically purged by Azure.${NC}"

echo -e "${YELLOW}📋 Deleting AKS node resource group: ${PROJECT_NAME}-node-rg${NC}"
az group delete --name "${PROJECT_NAME}-node-rg" --yes --no-wait 2>/dev/null \
    || echo -e "${YELLOW}⚠️  Node resource group not found or already deleted${NC}"

echo ""
read -p "Also delete Terraform state storage (${TF_RG})? [y/N]: " delete_state

if [[ "$delete_state" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}📋 Deleting Terraform state resource group: ${TF_RG}${NC}"
    az group delete --name "$TF_RG" --yes --no-wait 2>/dev/null \
        || echo -e "${YELLOW}⚠️  Terraform state resource group not found${NC}"
    echo -e "${GREEN}✅ Terraform state storage deletion initiated${NC}"
else
    echo -e "${BLUE}ℹ️  Terraform state storage preserved (${TF_RG})${NC}"
fi

echo ""
echo -e "${GREEN}✅ Deletion initiated! Resources being removed in the background.${NC}"
echo -e "${BLUE}📋 Deletion typically takes 10-15 minutes.${NC}"
echo ""
echo -e "${BLUE}📋 Monitor progress:${NC}"
echo "  az group list --query \"[?contains(name,'${PROJECT_NAME}')].{Name:name,State:properties.provisioningState}\" -o table"
echo ""
echo -e "${GREEN}🎉 Cleanup complete!${NC}"
