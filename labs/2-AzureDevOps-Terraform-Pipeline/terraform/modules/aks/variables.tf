

variable "name" {
  type        = string
  description = "Base name used for all AKS resources"
}

variable "location" {
  type        = string
  description = "Azure region for AKS resources"
  default     = "uksouth"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for AKS Linux node access"
  default     = "~/.ssh/id_rsa.pub"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the AKS cluster"
}

variable "vm_size" {
  type        = string
  description = "VM SKU for AKS system node pool"
}

variable "min_count" {
  type        = number
  description = "Minimum node count for auto-scaling"
  default     = 1
}

variable "max_count" {
  type        = number
  description = "Maximum node count for auto-scaling"
  default     = 3
}

variable "aks_admins_group_object_id" {
  type        = string
  description = "Object ID of the Azure AD group granted AKS admin access"
}

variable "aks_subnet" {
  type        = string
  description = "Resource ID of the subnet for AKS nodes"
}

variable "environment" {
  type        = string
  description = "Deployment environment label (e.g. production)"
}
