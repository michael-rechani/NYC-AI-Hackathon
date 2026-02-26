## Terraform configuration moved to provider.tf

# Resource Group
resource "azurerm_resource_group" "paas" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Network Security Group for App Service subnet
resource "azurerm_network_security_group" "appservice" {
  name                = "nsg-appservice"
  location            = azurerm_resource_group.paas.location
  resource_group_name = azurerm_resource_group.paas.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Network Security Group for Private Endpoint subnet
resource "azurerm_network_security_group" "privateendpoint" {
  name                = "nsg-privateendpoint"
  location            = azurerm_resource_group.paas.location
  resource_group_name = azurerm_resource_group.paas.name

  security_rule {
    name                       = "AllowSQL"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = var.appservice_subnet_prefix
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPSFromVNet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Virtual Network for VNet Integration
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1"

  parent_id     = azurerm_resource_group.paas.id
  location      = azurerm_resource_group.paas.location
  name          = var.vnet_name
  address_space = var.vnet_address_space

  tags = var.tags

  subnets = {
    appservice = {
      name                            = "appservice-subnet"
      address_prefixes                = [var.appservice_subnet_prefix]
      default_outbound_access_enabled = false
      delegations = [{
        name = "appservice-delegation"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
        }
      }]
      network_security_group = {
        id = azurerm_network_security_group.appservice.id
      }
      nat_gateway = {
        id = azurerm_nat_gateway.paas.id
      }
      service_endpoints_with_location = [{ service = "Microsoft.KeyVault" }]
    }
    privateendpoint = {
      name                              = "privateendpoint-subnet"
      address_prefixes                  = [var.privateendpoint_subnet_prefix]
      default_outbound_access_enabled   = false
      private_endpoint_network_policies = "Disabled"
      network_security_group = {
        id = azurerm_network_security_group.privateendpoint.id
      }
    }
  }

  depends_on = [
    azurerm_network_security_group.appservice,
    azurerm_network_security_group.privateendpoint
  ]
}

# NAT Gateway (shared) for App Service subnet outbound access
resource "azurerm_public_ip" "nat_gateway" {
  name                = "pip-${var.vnet_name}-nat"
  location            = azurerm_resource_group.paas.location
  resource_group_name = azurerm_resource_group.paas.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_nat_gateway" "paas" {
  name                = "nat-${var.vnet_name}"
  location            = azurerm_resource_group.paas.location
  resource_group_name = azurerm_resource_group.paas.name
  sku_name            = "Standard"

  tags = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "paas" {
  nat_gateway_id       = azurerm_nat_gateway.paas.id
  public_ip_address_id = azurerm_public_ip.nat_gateway.id
}

# Data source for Hub Key Vault
data "azurerm_key_vault" "hub" {
  name                = var.hub_key_vault_name
  resource_group_name = var.hub_resource_group_name
}

# Create random username and password for PaaS SQL Admin
resource "random_string" "sql_admin_username" {
  length  = 12
  special = false
  numeric = true
  upper   = true
  lower   = true
}

resource "random_password" "sql_admin" {
  length  = 16
  special = true
}

# Store PaaS SQL credentials in Hub Key Vault
resource "azurerm_key_vault_secret" "sql_admin_username" {
  name         = "paas-sql-admin-username"
  value        = random_string.sql_admin_username.result
  key_vault_id = data.azurerm_key_vault.hub.id
  content_type = "text/plain"

  tags = var.tags
}

resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "paas-sql-admin-password"
  value        = random_password.sql_admin.result
  key_vault_id = data.azurerm_key_vault.hub.id
  content_type = "text/plain"

  tags = var.tags
}

# App Service Plan (AVM)
module "app_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "1.0.0"

  name                = var.app_service_plan_name
  location            = azurerm_resource_group.paas.location
  resource_group_name = azurerm_resource_group.paas.name

  os_type  = var.app_service_os_type
  sku_name = var.app_service_sku

  worker_count           = var.app_service_worker_count
  zone_balancing_enabled = var.app_service_zone_balancing

  tags = var.tags
}

# SQL Server
resource "azurerm_mssql_server" "sql" {
  name                          = var.sql_server_name
  resource_group_name           = azurerm_resource_group.paas.name
  location                      = azurerm_resource_group.paas.location
  version                       = var.sql_server_version
  administrator_login           = random_string.sql_admin_username.result
  administrator_login_password  = random_password.sql_admin.result
  public_network_access_enabled = var.sql_public_access_enabled

  lifecycle {
    ignore_changes = [azuread_administrator]
  }

  tags = var.tags
}

# SQL Database
resource "azurerm_mssql_database" "app" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.sql.id
  sku_name       = var.sql_database_sku
  max_size_gb    = var.sql_database_max_size_gb
  zone_redundant = var.sql_database_zone_redundant
  read_scale     = var.sql_database_read_scale

  auto_pause_delay_in_minutes = var.sql_database_serverless ? var.sql_database_auto_pause_delay : null
  min_capacity                = var.sql_database_serverless ? var.sql_database_min_capacity : null

  tags = var.tags
}

# SQL Firewall Rule
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  count            = var.enable_sql_firewall_rules ? 1 : 0
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Unified Web App - Windows
resource "azurerm_windows_web_app" "app" {
  count               = var.app_service_os_type == "Windows" ? 1 : 0
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.paas.name
  location            = azurerm_resource_group.paas.location
  service_plan_id     = module.app_service_plan.resource_id
  https_only          = true

  site_config {
    always_on              = var.app_service_always_on
    ftps_state             = "FtpsOnly"
    http2_enabled          = true
    minimum_tls_version    = "1.2"
    vnet_route_all_enabled = true

    application_stack {
      current_stack  = var.app_service_runtime_stack
      dotnet_version = var.app_service_runtime_version
    }
  }

  app_settings = merge(
    var.app_service_app_settings,
    {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
    }
  )

  dynamic "connection_string" {
    for_each = var.enable_sql_connection ? [1] : []
    content {
      name  = "DefaultConnection"
      type  = "SQLAzure"
      value = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${var.sql_database_name};Persist Security Info=False;User ID=${random_string.sql_admin_username.result};Password=${random_password.sql_admin.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    }
  }

  virtual_network_subnet_id = module.virtual_network.subnets["appservice"].resource_id

  public_network_access_enabled = var.app_service_public_access_enabled

  lifecycle {
    ignore_changes = [ftp_publish_basic_authentication_enabled, webdeploy_publish_basic_authentication_enabled]
  }

  tags = var.tags
}

# Unified Web App - Linux
resource "azurerm_linux_web_app" "app" {
  count               = var.app_service_os_type == "Linux" ? 1 : 0
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.paas.name
  location            = azurerm_resource_group.paas.location
  service_plan_id     = module.app_service_plan.resource_id
  https_only          = true

  site_config {
    always_on              = var.app_service_always_on
    ftps_state             = "FtpsOnly"
    http2_enabled          = true
    minimum_tls_version    = "1.2"
    vnet_route_all_enabled = true

    application_stack {
      dotnet_version = var.app_service_runtime_stack == "dotnet" ? var.app_service_runtime_version : null
      node_version   = var.app_service_runtime_stack == "node" ? var.app_service_runtime_version : null
      python_version = var.app_service_runtime_stack == "python" ? var.app_service_runtime_version : null
    }
  }

  app_settings = merge(
    var.app_service_app_settings,
    {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
    }
  )

  dynamic "connection_string" {
    for_each = var.enable_sql_connection ? [1] : []
    content {
      name  = "DefaultConnection"
      type  = "SQLAzure"
      value = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${var.sql_database_name};Persist Security Info=False;User ID=${random_string.sql_admin_username.result};Password=${random_password.sql_admin.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    }
  }

  virtual_network_subnet_id = module.virtual_network.subnets["appservice"].resource_id

  public_network_access_enabled = var.app_service_public_access_enabled

  tags = var.tags
}

# Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "sql" {
  count               = var.enable_sql_private_endpoint ? 1 : 0
  name                = "${var.sql_server_name}-pe"
  location            = azurerm_resource_group.paas.location
  resource_group_name = azurerm_resource_group.paas.name
  subnet_id           = module.virtual_network.subnets["privateendpoint"].resource_id

  private_service_connection {
    name                           = "${var.sql_server_name}-psc"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-private-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.paas.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "sql-private-dns-link"
  resource_group_name   = azurerm_resource_group.paas.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}

# Private Endpoint for App Service
resource "azurerm_private_endpoint" "app_service" {
  count               = var.enable_app_service_private_endpoint ? 1 : 0
  name                = "${var.app_service_name}-pe"
  location            = azurerm_resource_group.paas.location
  resource_group_name = azurerm_resource_group.paas.name
  subnet_id           = module.virtual_network.subnets["privateendpoint"].resource_id

  private_service_connection {
    name                           = "${var.app_service_name}-psc"
    private_connection_resource_id = var.app_service_os_type == "Windows" ? azurerm_windows_web_app.app[0].id : azurerm_linux_web_app.app[0].id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "appservice-private-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.app_service.id]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "app_service" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.paas.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "app_service" {
  name                  = "appservice-private-dns-link"
  resource_group_name   = azurerm_resource_group.paas.name
  private_dns_zone_name = azurerm_private_dns_zone.app_service.name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}

# Application Insights for monitoring
resource "azurerm_application_insights" "app" {
  name                = "${var.app_service_name}-ai"
  location            = azurerm_resource_group.paas.location
  resource_group_name = azurerm_resource_group.paas.name
  application_type    = "web"
  tags                = var.tags
}

# ──────────────────────────────────────────────
# Key Vault Private DNS Zone Link
# ──────────────────────────────────────────────

data "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.hub_resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_paas" {
  name                  = "kv-paas-link"
  resource_group_name   = var.hub_resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}

# Data source for hub VNet
data "azurerm_virtual_network" "hub" {
  count               = var.enable_vnet_peering ? 1 : 0
  name                = var.hub_vnet_name
  resource_group_name = var.hub_vnet_resource_group
}

# VNet Peering from PaaS to Hub
resource "azurerm_virtual_network_peering" "paas_to_hub" {
  count                     = var.enable_vnet_peering ? 1 : 0
  name                      = "paas-to-hub"
  resource_group_name       = azurerm_resource_group.paas.name
  virtual_network_name      = module.virtual_network.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub[0].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# VNet Peering from Hub to PaaS
resource "azurerm_virtual_network_peering" "hub_to_paas" {
  count                     = var.enable_vnet_peering ? 1 : 0
  name                      = "hub-to-paas"
  resource_group_name       = var.hub_vnet_resource_group
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = module.virtual_network.resource_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
