variable "name" {
}

variable "location" {
  default = "uksouth"
}

variable "application_type" {
}

variable "environment" {
}

variable "workspace_id" {
  description = "Log Analytics Workspace ID for workspace-based Application Insights"
}
