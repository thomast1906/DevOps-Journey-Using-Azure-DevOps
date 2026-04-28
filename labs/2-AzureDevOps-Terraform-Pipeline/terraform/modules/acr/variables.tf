variable "name" {
  type        = string
  description = "Base name used for all ACR resources"
}

variable "location" {
  type        = string
  description = "Azure region for ACR resources (unused; location is read from the shared resource group)"
  default     = "uksouth"
}

variable "environment" {
  type        = string
  description = "Deployment environment label (e.g. production)"
}
