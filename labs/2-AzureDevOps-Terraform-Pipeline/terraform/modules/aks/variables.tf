

variable "name" {
}

variable "location" {
  default = "uksouth"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "kubernetes_version" {
}

variable "vm_size" {
}

variable "min_count" {
  description = "Minimum node count for auto-scaling"
  default     = 1
}

variable "max_count" {
  description = "Maximum node count for auto-scaling"
  default     = 3
}

variable "aks_admins_group_object_id" {
  description = "Object ID of the Azure AD group granted AKS admin access"
}

variable "aks_subnet" {
}

variable "environment" {
}
