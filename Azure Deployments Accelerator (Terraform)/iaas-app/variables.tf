variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

# Network Variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "web_subnet_prefix" {
  description = "Address prefix for the web subnet"
  type        = string
}

variable "data_subnet_prefix" {
  description = "Address prefix for the data subnet"
  type        = string
}

variable "paas_app_subnet_prefix" {
  description = "Address prefix for the PaaS app service subnet (for cross-vnet SQL access)"
  type        = string
}

# Web VM Variables
variable "web_vm_name" {
  description = "Name of the web VM"
  type        = string
}

variable "web_vm_size" {
  description = "VM size for the web server"
  type        = string
}

variable "web_image" {
  description = "Source image reference for the web VM"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "web_vm_zone" {
  description = "Availability zone for the web VM (1, 2, 3, or null)"
  type        = string
}

# SQL VM Variables
variable "sql_vm_name" {
  description = "Name of the SQL VM"
  type        = string
}

variable "sql_vm_size" {
  description = "VM size for the SQL server"
  type        = string
}

variable "sql_image" {
  description = "Source image reference for the SQL VM"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "sql_vm_zone" {
  description = "Availability zone for the SQL VM (1, 2, 3, or null)"
  type        = string
}

variable "sql_data_disk_size_gb" {
  description = "Size of SQL data disk in GB"
  type        = number
}

variable "sql_log_disk_size_gb" {
  description = "Size of SQL log disk in GB"
  type        = number
}

variable "sql_license_type" {
  description = "SQL Server license type (PAYG, AHUB, or DR)"
  type        = string
}

variable "sql_workload_type" {
  description = "SQL Server workload type (GENERAL, OLTP, or DW)"
  type        = string
}

# Hub references
variable "hub_resource_group_name" {
  description = "Name of the hub resource group for VNet peering"
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the hub VNet for peering"
  type        = string
}

variable "hub_jumpbox_subnet_prefix" {
  description = "Jumpbox subnet prefix in the hub VNet for admin access NSG rules"
  type        = string
}

variable "hub_key_vault_name" {
  description = "Name of the hub Key Vault for storing credentials"
  type        = string
}

variable "hub_key_vault_resource_group" {
  description = "Resource group name containing the hub Key Vault"
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
