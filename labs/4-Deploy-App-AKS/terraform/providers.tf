provider "azurerm" {
    version = "~> 4.0"
    features {}
}

terraform {
    backend "azurerm" {
      resource_group_name = "devops-journey-rg"   
      storage_account_name = "devopsjourneyazuredevops"
      container_name = "terraform.tfstate`"
    }
}

data "azurerm_client_config" "current" {}