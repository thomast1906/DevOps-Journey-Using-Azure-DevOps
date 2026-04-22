variable "name" {
  type        = string
  description = "Base name used for all Key Vault resources"
}

variable "admin_object_id" {
  type        = string
  description = "Object ID of the principal to assign Key Vault Administrator role"
}
