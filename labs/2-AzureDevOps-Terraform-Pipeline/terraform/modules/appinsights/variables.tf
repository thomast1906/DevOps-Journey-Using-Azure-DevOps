variable "name" {
  type        = string
  description = "Base name used for all Application Insights resources"
}

variable "location" {
  type        = string
  description = "Azure region for Application Insights resources"
  default     = "uksouth"
}

variable "application_type" {
  type        = string
  description = "Application type for Application Insights (e.g. web)"
}

variable "environment" {
  type        = string
  description = "Deployment environment label (e.g. production)"
}

variable "workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for workspace-based Application Insights"
}
