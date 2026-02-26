output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.paas.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.virtual_network.resource_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.virtual_network.name
}

output "app_service_plan_id" {
  description = "ID of the App Service Plan"
  value       = module.app_service_plan.resource_id
}

output "app_service_id" {
  description = "ID of the App Service"
  value       = var.app_service_os_type == "Windows" ? azurerm_windows_web_app.app[0].id : azurerm_linux_web_app.app[0].id
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = var.app_service_os_type == "Windows" ? azurerm_windows_web_app.app[0].name : azurerm_linux_web_app.app[0].name
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service"
  value       = var.app_service_os_type == "Windows" ? azurerm_windows_web_app.app[0].default_hostname : azurerm_linux_web_app.app[0].default_hostname
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = "https://${var.app_service_os_type == "Windows" ? azurerm_windows_web_app.app[0].default_hostname : azurerm_linux_web_app.app[0].default_hostname}"
}

output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_mssql_server.sql.id
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.sql.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = var.sql_database_name
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.app.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = azurerm_application_insights.app.connection_string
  sensitive   = true
}
