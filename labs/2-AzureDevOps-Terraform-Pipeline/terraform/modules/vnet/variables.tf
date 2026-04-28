variable "name" {
  type        = string
  description = "Base name used for all VNet resources"
}

variable "location" {
  type        = string
  description = "Azure region for VNet resources"
  default     = "uksouth"
}

variable "network_address_space" {
  type        = string
  description = "CIDR block for the virtual network"
}

variable "aks_subnet_address_prefix" {
  type        = string
  description = "CIDR block for the AKS subnet"
}

variable "aks_subnet_address_name" {
  type        = string
  description = "Name for the AKS subnet"
}

variable "appgw_subnet_address_prefix" {
  type        = string
  description = "CIDR block for the Application Gateway subnet"
}

variable "appgw_subnet_address_name" {
  type        = string
  description = "Name for the Application Gateway subnet"
}

variable "environment" {
  type        = string
  description = "Deployment environment label (e.g. production)"
}
