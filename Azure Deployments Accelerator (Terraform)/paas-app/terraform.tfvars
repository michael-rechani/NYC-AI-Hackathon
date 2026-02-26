# ──────────────────────────────────────────────
# PaaS App Infrastructure - terraform.tfvars
# ──────────────────────────────────────────────
# Customize values for your deployment.
# NOTE: No secrets in this file — credentials are auto-generated and stored in Key Vault.

# Azure Subscription
subscription_id = ""

# Resource Group
resource_group_name = "rg-paas-workshop"
location            = "eastus"

# Network
vnet_name                     = "vnet-paas-workshop"
vnet_address_space            = ["10.2.0.0/16"]
appservice_subnet_prefix      = "10.2.1.0/24"
privateendpoint_subnet_prefix = "10.2.2.0/24"

# VNet Peering
enable_vnet_peering     = true
hub_vnet_name           = "vnet-hub-workshop"
hub_vnet_resource_group = "rg-hub-workshop"

# App Service Plan (AVM)
app_service_plan_name      = "asp-paas-workshop"
app_service_os_type        = "Windows"
app_service_sku            = "S1"
app_service_worker_count   = 1
app_service_zone_balancing = false

# App Service
app_service_name                    = "app-paas-workshop"
app_service_public_access_enabled   = false
enable_app_service_private_endpoint = true
app_service_always_on               = true
app_service_runtime_stack           = "dotnet"
app_service_runtime_version         = "v8.0"

# SQL Server (name must be globally unique)
sql_server_name           = "sql-paas-workshop"
sql_server_version        = "12.0"
sql_public_access_enabled = false

# SQL Database
sql_database_name             = "sqldb-paas-workshop"
sql_database_sku              = "GP_S_Gen5_2"
sql_database_max_size_gb      = 32
sql_database_zone_redundant   = false
sql_database_read_scale       = false
sql_database_serverless       = true
sql_database_auto_pause_delay = 60
sql_database_min_capacity     = 0.5

# SQL connectivity
enable_sql_firewall_rules   = false
enable_sql_private_endpoint = true
enable_sql_connection       = true

# Hub Key Vault reference (must match hub deployment)
hub_key_vault_name      = "kv-hubworkshop"
hub_resource_group_name = "rg-hub-workshop"

# Tags
tags = {
  Environment = "App-&-AIAgents-Workshop"
  ManagedBy   = "Terraform"
}
