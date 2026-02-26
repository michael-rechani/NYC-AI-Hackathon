# ──────────────────────────────────────────────
# AI Foundry Infrastructure - terraform.tfvars
# ──────────────────────────────────────────────
# Customize values for your deployment.
# NOTE: No secrets in this file — credentials are stored in Key Vault.

# Azure Subscription
subscription_id = ""

# Resource Group
resource_group_name = "rg-ai-workshop"
location            = "eastus"

# Network
vnet_name                     = "vnet-ai-workshop"
vnet_address_space            = ["10.3.0.0/16"]
ai_subnet_prefix              = "10.3.1.0/24"
privateendpoint_subnet_prefix = "10.3.2.0/24"

# VNet Peering
enable_vnet_peering     = true
hub_vnet_name           = "vnet-hub-workshop"
hub_vnet_resource_group = "rg-hub-workshop"

# Hub references (must match hub deployment)
hub_resource_group_name = "rg-hub-workshop"
hub_key_vault_name      = "kv-hubworkshop"

# AI Foundry Hub
ai_hub_name                  = "aihub-workshop"
ai_hub_display_name          = "Workshop AI Foundry Hub"
ai_hub_description           = "Azure AI Foundry hub for App-in-a-Day Workshop"
ai_hub_public_network_access = "Disabled"
ai_hub_sku                   = "Basic"

# AI Foundry Project
ai_project_name         = "aiproj-sql-workshop"
ai_project_display_name = "SQL Workloads Project"

# AI Services (Cognitive Services multi-service)
ai_services_name                  = "ais-workshop"
ai_services_sku                   = "S0"
ai_services_public_network_access = false

# OpenAI Model Deployments
openai_deployments = {
  "gpt-4o" = {
    model_name    = "gpt-4o"
    model_version = "2024-11-20"
    sku_name      = "GlobalStandard"
    sku_capacity  = 10
  }
  # Uncomment to add an embedding model for vector search in Azure SQL
  # "text-embedding-3-small" = {
  #   model_name    = "text-embedding-3-small"
  #   model_version = "1"
  #   sku_name      = "Standard"
  #   sku_capacity  = 10
  # }
}

# Storage Account (name must be globally unique, 3-24 chars, lowercase alphanumeric)
storage_account_name        = "staifoundryworkshop"
storage_account_tier        = "Standard"
storage_account_replication = "LRS"

# Container Registry (optional — enable if deploying custom model images)
enable_container_registry = false
container_registry_name   = "acraifoundryworkshop"
container_registry_sku    = "Premium"

# ──────────────────────────────────────────────
# SQL Connections
# ──────────────────────────────────────────────

# PaaS Azure SQL Database (direct private endpoint — first-class support)
enable_paas_sql_connection     = true
paas_sql_server_name           = "sql-paas-workshop"
paas_sql_server_resource_group = "rg-paas-workshop"
paas_sql_database_name         = "sqldb-paas-workshop"

# IaaS SQL VM (via Private Link Service — requires PLS in iaas-app)
# Set to true after deploying the PLS in iaas-app module
enable_iaas_sql_pls              = false
iaas_sql_private_link_service_id = ""

# Tags
tags = {
  Environment = "App-&-AIAgents-Workshop"
  ManagedBy   = "Terraform"
}
