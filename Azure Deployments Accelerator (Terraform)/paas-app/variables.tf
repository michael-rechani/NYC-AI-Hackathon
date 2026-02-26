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

variable "appservice_subnet_prefix" {
  description = "Address prefix for the App Service subnet"
  type        = string
}

variable "privateendpoint_subnet_prefix" {
  description = "Address prefix for the private endpoint subnet"
  type        = string
}

variable "enable_vnet_peering" {
  description = "Enable VNet peering with hub VNet"
  type        = bool
}

variable "hub_vnet_name" {
  description = "Name of the hub VNet to peer with"
  type        = string
}

variable "hub_vnet_resource_group" {
  description = "Resource group name of the hub VNet"
  type        = string
}

# App Service Plan Variables
variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
}

variable "app_service_os_type" {
  description = "OS type for App Service (Windows or Linux)"
  type        = string
  validation {
    condition     = contains(["Windows", "Linux"], var.app_service_os_type)
    error_message = "app_service_os_type must be 'Windows' or 'Linux'"
  }
}

variable "app_service_sku" {
  description = "SKU for App Service Plan (e.g., P1v3, B1, S1)"
  type        = string
}

variable "app_service_worker_count" {
  description = "Number of workers for App Service Plan"
  type        = number
}

variable "app_service_zone_balancing" {
  description = "Enable zone balancing for App Service Plan (requires P1v2+ SKU)"
  type        = bool
}

# App Service Variables
variable "app_service_name" {
  description = "Name of the App Service"
  type        = string
}

variable "app_service_public_access_enabled" {
  description = "Enable public network access for App Service"
  type        = bool
}

variable "enable_app_service_private_endpoint" {
  description = "Enable private endpoint for App Service"
  type        = bool
}

variable "app_service_always_on" {
  description = "Enable always on for App Service"
  type        = bool
}

variable "app_service_runtime_stack" {
  description = "Runtime stack for App Service (e.g., dotnet, node, python)"
  type        = string
}

variable "app_service_runtime_version" {
  description = "Runtime version for App Service"
  type        = string
}

variable "app_service_app_settings" {
  description = "App settings for App Service"
  type        = map(string)
  default     = {}
}

# SQL Server Variables
variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "sql_server_version" {
  description = "Version of SQL Server (e.g., 12.0)"
  type        = string
}

variable "sql_public_access_enabled" {
  description = "Enable public network access for SQL Server"
  type        = bool
}

variable "enable_sql_firewall_rules" {
  description = "Enable SQL Server firewall rule for Azure services"
  type        = bool
}

variable "enable_sql_private_endpoint" {
  description = "Enable private endpoint for SQL Server"
  type        = bool
}

variable "enable_sql_connection" {
  description = "Add SQL connection string to App Service"
  type        = bool
}

# SQL Database Variables
variable "sql_database_name" {
  description = "Name of the SQL Database"
  type        = string
}

variable "sql_database_sku" {
  description = "SKU for SQL Database (e.g., Basic, S0, P1, GP_Gen5_2)"
  type        = string
}

variable "sql_database_max_size_gb" {
  description = "Maximum size of the database in GB"
  type        = number
}

variable "sql_database_zone_redundant" {
  description = "Enable zone redundancy for SQL Database"
  type        = bool
}

variable "sql_database_read_scale" {
  description = "Enable read scale-out for SQL Database"
  type        = bool
}

variable "sql_database_serverless" {
  description = "Whether the SQL Database uses a serverless SKU"
  type        = bool
}

variable "sql_database_auto_pause_delay" {
  description = "Auto-pause delay in minutes for serverless databases (-1 to disable)"
  type        = number
}

variable "sql_database_min_capacity" {
  description = "Minimum capacity for serverless databases"
  type        = number
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "hub_key_vault_name" {
  description = "Name of the hub Key Vault for retrieving secrets"
  type        = string
}

variable "hub_resource_group_name" {
  description = "Resource group name of the hub for Key Vault access"
  type        = string
}
