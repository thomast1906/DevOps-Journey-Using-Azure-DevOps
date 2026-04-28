variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of the Log Analytics Workspace"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
variable "log_analytics_workspace_sku" {
  type        = string
  description = "SKU of the Log Analytics Workspace (e.g. PerGB2018)"
}

variable "location" {
  type        = string
  description = "Azure region for Log Analytics resources"
  default     = "uksouth"
}

variable "environment" {
  type        = string
  description = "Deployment environment label (e.g. production)"
}