output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.ai.name
}

output "vnet_id" {
  description = "ID of the AI Foundry virtual network"
  value       = module.virtual_network.resource_id
}

output "vnet_name" {
  description = "Name of the AI Foundry virtual network"
  value       = module.virtual_network.name
}

output "ai_subnet_id" {
  description = "ID of the AI subnet"
  value       = module.virtual_network.subnets["ai"].resource_id
}

output "privateendpoint_subnet_id" {
  description = "ID of the private endpoint subnet"
  value       = module.virtual_network.subnets["privateendpoint"].resource_id
}

# ──────────────────────────────────────────────
# AI Foundry Hub
# ──────────────────────────────────────────────

output "ai_hub_id" {
  description = "ID of the AI Foundry hub"
  value       = azurerm_ai_foundry.hub.id
}

output "ai_hub_name" {
  description = "Name of the AI Foundry hub"
  value       = azurerm_ai_foundry.hub.name
}

output "ai_hub_principal_id" {
  description = "Principal ID of the AI Foundry hub managed identity"
  value       = azurerm_ai_foundry.hub.identity[0].principal_id
}

# ──────────────────────────────────────────────
# AI Foundry Project
# ──────────────────────────────────────────────

output "ai_project_id" {
  description = "ID of the AI Foundry project"
  value       = azurerm_ai_foundry_project.project.id
}

output "ai_project_name" {
  description = "Name of the AI Foundry project"
  value       = azurerm_ai_foundry_project.project.name
}

output "ai_project_principal_id" {
  description = "Principal ID of the AI Foundry project managed identity"
  value       = azurerm_ai_foundry_project.project.identity[0].principal_id
}

# ──────────────────────────────────────────────
# AI Services
# ──────────────────────────────────────────────

output "ai_services_id" {
  description = "ID of the Azure AI Services account"
  value       = azurerm_cognitive_account.ai_services.id
}

output "ai_services_endpoint" {
  description = "Endpoint of the Azure AI Services account"
  value       = azurerm_cognitive_account.ai_services.endpoint
}

output "ai_services_name" {
  description = "Name of the Azure AI Services account"
  value       = azurerm_cognitive_account.ai_services.name
}

# ──────────────────────────────────────────────
# Storage
# ──────────────────────────────────────────────

output "storage_account_id" {
  description = "ID of the AI Foundry storage account"
  value       = azurerm_storage_account.ai.id
}

output "storage_account_name" {
  description = "Name of the AI Foundry storage account"
  value       = azurerm_storage_account.ai.name
}

# ──────────────────────────────────────────────
# SQL Connectivity
# ──────────────────────────────────────────────

output "paas_sql_private_endpoint_ip" {
  description = "Private IP of the Azure SQL private endpoint (if enabled)"
  value       = var.enable_paas_sql_connection ? azurerm_private_endpoint.paas_sql[0].private_service_connection[0].private_ip_address : null
}

output "iaas_sql_private_endpoint_ip" {
  description = "Private IP of the IaaS SQL VM private endpoint via PLS (if enabled)"
  value       = var.enable_iaas_sql_pls ? azurerm_private_endpoint.iaas_sql[0].private_service_connection[0].private_ip_address : null
}

# ──────────────────────────────────────────────
# Monitoring
# ──────────────────────────────────────────────

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.ai.id
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = azurerm_application_insights.ai.connection_string
  sensitive   = true
}
