# Terraform Variables for SMS Project

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "sms-devops-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "sms"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key for VM access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "db_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "smsadmin"
}

variable "db_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}
