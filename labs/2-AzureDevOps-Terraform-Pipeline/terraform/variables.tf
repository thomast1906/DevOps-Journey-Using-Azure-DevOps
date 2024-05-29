variable "location" {
  type        = string
  description = "Location of Resources"
}

variable "vnet_name" {
  type        = string
  description = "Virtual Network Name"
}

variable "network_address_space" {
  type        = string
  description = "Virtual Network Address Space"
}


variable "aks_subnet_address_prefix" {
  type        = string
  description = "AKS Subnet Address Prefix"
}

variable "aks_subnet_address_name" {
  type        = string
  description = "AKS Subnet Name"
}

variable "appgw_subnet_address_prefix" {
  type        = string
  description = "AppGW Subnet Address Prefix"
}

variable "appgw_subnet_address_name" {
  type        = string
  description = "AppGW Subnet Name"
}

variable "aks_name" {
  type        = string
  description = "AKS Name"
}

variable "kubernetes_version" {
  type        = string
  description = "AKS K8s Version"
}

variable "agent_count" {
  type        = string
  description = "AKS Agent Count"
}

variable "vm_size" {
  type        = string
  description = "AKS VM Size"
}

variable "general_name" {
  type        = string
  description = "General Name"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH key for AKS Cluster"
}