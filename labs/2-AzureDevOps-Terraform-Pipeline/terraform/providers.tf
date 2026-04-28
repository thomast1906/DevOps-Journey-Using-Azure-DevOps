terraform {
  required_version = ">= 1.14.0, < 2.0.0"
  backend "azurerm" {
    # resource_group_name  = "devopshardway-rg"
    # storage_account_name = "devopshardwaysa"
    # container_name       = "tfstate"
    # key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.70.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  # subscription_id is sourced from the ARM_SUBSCRIPTION_ID environment variable
  # set automatically by the Azure DevOps Workload Identity Federation service connection
}

data "azurerm_client_config" "current" {}