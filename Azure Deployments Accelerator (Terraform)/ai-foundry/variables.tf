variable "resource_group_name" {
  description = "Name of the resource group for AI Foundry resources"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

# ──────────────────────────────────────────────
# Network Variables
# ──────────────────────────────────────────────

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "ai_subnet_prefix" {
  description = "Address prefix for the AI services subnet (compute instances, managed endpoints)"
  type        = string
}

variable "privateendpoint_subnet_prefix" {
  description = "Address prefix for the private endpoint subnet"
  type        = string
}

# ──────────────────────────────────────────────
# VNet Peering Variables
# ──────────────────────────────────────────────

variable "enable_vnet_peering" {
  description = "Enable VNet peering with hub VNet"
  type        = bool
  default     = true
}

variable "hub_vnet_name" {
  description = "Name of the hub VNet to peer with"
  type        = string
}

variable "hub_vnet_resource_group" {
  description = "Resource group name of the hub VNet"
  type        = string
}

# ──────────────────────────────────────────────
# Hub References
# ──────────────────────────────────────────────

variable "hub_resource_group_name" {
  description = "Resource group name of the hub (for Key Vault, DNS zones)"
  type        = string
}

variable "hub_key_vault_name" {
  description = "Name of the hub Key Vault for storing secrets"
  type        = string
}

# ──────────────────────────────────────────────
# AI Foundry Hub Variables
# ──────────────────────────────────────────────

variable "ai_hub_name" {
  description = "Name of the Azure AI Foundry hub"
  type        = string
}

variable "ai_hub_display_name" {
  description = "Display name for the AI Foundry hub"
  type        = string
  default     = "AI Foundry Hub"
}

variable "ai_hub_description" {
  description = "Description for the AI Foundry hub"
  type        = string
  default     = "Azure AI Foundry hub for workshop workloads"
}

variable "ai_hub_public_network_access" {
  description = "Whether public network access is allowed for the AI hub (Enabled or Disabled)"
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.ai_hub_public_network_access)
    error_message = "ai_hub_public_network_access must be 'Enabled' or 'Disabled'"
  }
}

variable "ai_hub_sku" {
  description = "SKU for the AI Foundry hub (informational — reserved for future use)"
  type        = string
  default     = "Basic"
}

# ──────────────────────────────────────────────
# AI Foundry Project Variables
# ──────────────────────────────────────────────

variable "ai_project_name" {
  description = "Name of the Azure AI Foundry project"
  type        = string
}

variable "ai_project_display_name" {
  description = "Display name for the AI Foundry project"
  type        = string
  default     = "SQL Workloads Project"
}

# ──────────────────────────────────────────────
# AI Services (Cognitive Services) Variables
# ──────────────────────────────────────────────

variable "ai_services_name" {
  description = "Name of the Azure AI Services account (multi-service Cognitive Services)"
  type        = string
}

variable "ai_services_sku" {
  description = "SKU for Azure AI Services"
  type        = string
  default     = "S0"
}

variable "ai_services_public_network_access" {
  description = "Whether public network access is allowed for AI Services"
  type        = bool
  default     = false
}

# ──────────────────────────────────────────────
# OpenAI Model Deployment Variables
# ──────────────────────────────────────────────

variable "openai_deployments" {
  description = "Map of OpenAI model deployments"
  type = map(object({
    model_name    = string
    model_version = string
    sku_name      = string
    sku_capacity  = number
  }))
  default = {}
}

# ──────────────────────────────────────────────
# Storage Account Variables
# ──────────────────────────────────────────────

variable "storage_account_name" {
  description = "Name of the storage account for AI Foundry artifacts"
  type        = string
}

variable "storage_account_tier" {
  description = "Performance tier for the storage account"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication" {
  description = "Replication type for the storage account"
  type        = string
  default     = "LRS"
}

# ──────────────────────────────────────────────
# Container Registry Variables
# ──────────────────────────────────────────────

variable "enable_container_registry" {
  description = "Enable Azure Container Registry for custom model images"
  type        = bool
  default     = false
}

variable "container_registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = ""
}

variable "container_registry_sku" {
  description = "SKU for Container Registry (Basic, Standard, Premium). Premium required for private endpoint."
  type        = string
  default     = "Premium"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.container_registry_sku)
    error_message = "container_registry_sku must be 'Basic', 'Standard', or 'Premium'"
  }
}

# ──────────────────────────────────────────────
# SQL Connection Variables
# ──────────────────────────────────────────────

variable "enable_paas_sql_connection" {
  description = "Enable managed private endpoint to PaaS Azure SQL Database"
  type        = bool
  default     = true
}

variable "paas_sql_server_name" {
  description = "Name of the PaaS SQL Server to connect to (e.g., sql-paas-workshop)"
  type        = string
  default     = ""
}

variable "paas_sql_server_resource_group" {
  description = "Resource group of the PaaS SQL Server"
  type        = string
  default     = ""
}

variable "paas_sql_database_name" {
  description = "Name of the PaaS SQL Database"
  type        = string
  default     = ""
}

variable "enable_iaas_sql_pls" {
  description = "Enable private endpoint to IaaS SQL VM via Private Link Service (requires PLS to be deployed in iaas-app)"
  type        = bool
  default     = false
}

variable "iaas_sql_private_link_service_id" {
  description = "Resource ID of the Private Link Service in front of the IaaS SQL VM (created in iaas-app module)"
  type        = string
  default     = ""
}

# ──────────────────────────────────────────────
# Tags
# ──────────────────────────────────────────────

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
