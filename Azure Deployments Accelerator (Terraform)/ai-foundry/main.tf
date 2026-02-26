# ──────────────────────────────────────────────
# Resource Group
# ──────────────────────────────────────────────

resource "azurerm_resource_group" "ai" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ──────────────────────────────────────────────
# Networking
# ──────────────────────────────────────────────

# NSG for AI subnet
resource "azurerm_network_security_group" "ai" {
  name                = "nsg-ai"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name

  security_rule {
    name                       = "AllowHTTPSOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  security_rule {
    name                       = "AllowAzureMachineLearning"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "44224"
    source_address_prefix      = "AzureMachineLearning"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowBatchNodeManagement"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "29876-29877"
    source_address_prefix      = "BatchNodeManagement"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# NSG for Private Endpoint subnet
resource "azurerm_network_security_group" "privateendpoint" {
  name                = "nsg-ai-privateendpoint"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name

  security_rule {
    name                       = "AllowHTTPSFromVNet"
    priority                   = 100
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

# Virtual Network
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1"

  parent_id     = azurerm_resource_group.ai.id
  location      = azurerm_resource_group.ai.location
  name          = var.vnet_name
  address_space = var.vnet_address_space

  tags = var.tags

  subnets = {
    ai = {
      name                            = "ai-subnet"
      address_prefixes                = [var.ai_subnet_prefix]
      default_outbound_access_enabled = false
      network_security_group = {
        id = azurerm_network_security_group.ai.id
      }
      nat_gateway = {
        id = azurerm_nat_gateway.ai.id
      }
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
    azurerm_network_security_group.ai,
    azurerm_network_security_group.privateendpoint
  ]
}

# NAT Gateway for AI subnet outbound access
resource "azurerm_public_ip" "nat_gateway" {
  name                = "pip-${var.vnet_name}-nat"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "ai" {
  name                = "nat-${var.vnet_name}"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "ai" {
  nat_gateway_id       = azurerm_nat_gateway.ai.id
  public_ip_address_id = azurerm_public_ip.nat_gateway.id
}

# ──────────────────────────────────────────────
# Auto-detect deployer's public IP for Key Vault firewall
# ──────────────────────────────────────────────

data "http" "my_ip" {
  url = "https://api.ipify.org"
}

# ──────────────────────────────────────────────
# Hub Key Vault Reference
# ──────────────────────────────────────────────

data "azurerm_key_vault" "hub" {
  name                = var.hub_key_vault_name
  resource_group_name = var.hub_resource_group_name
}

# Add deployer's current public IP to Key Vault firewall
# so Terraform (and the deployer) can read/write secrets
resource "azapi_update_resource" "kv_deployer_ip" {
  type        = "Microsoft.KeyVault/vaults@2024-04-01-preview"
  resource_id = data.azurerm_key_vault.hub.id

  body = {
    properties = {
      publicNetworkAccess = "Enabled"
      networkAcls = {
        bypass        = "AzureServices"
        defaultAction = "Deny"
        ipRules = [
          {
            value = "${chomp(data.http.my_ip.response_body)}/32"
          }
        ]
      }
    }
  }
}

# ──────────────────────────────────────────────
# Storage Account (AI Foundry artifact store)
# ──────────────────────────────────────────────

resource "random_string" "storage_suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_storage_account" "ai" {
  name                            = "${var.storage_account_name}${random_string.storage_suffix.result}"
  location                        = azurerm_resource_group.ai.location
  resource_group_name             = azurerm_resource_group.ai.name
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true

  tags = var.tags
}

# Private Endpoint for Storage Account (blob)
resource "azurerm_private_endpoint" "storage_blob" {
  name                = "${var.storage_account_name}-blob-pe"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  subnet_id           = module.virtual_network.subnets["privateendpoint"].resource_id

  private_service_connection {
    name                           = "${var.storage_account_name}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.ai.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "storage-blob-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_blob.id]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.ai.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "storage-blob-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob_hub" {
  count                 = var.enable_vnet_peering ? 1 : 0
  name                  = "storage-blob-hub-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = data.azurerm_virtual_network.hub[0].id
  registration_enabled  = false
  tags                  = var.tags
}

# Private Endpoint for Storage Account (file) — required by AI Foundry
resource "azurerm_private_endpoint" "storage_file" {
  name                = "${var.storage_account_name}-file-pe"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  subnet_id           = module.virtual_network.subnets["privateendpoint"].resource_id

  private_service_connection {
    name                           = "${var.storage_account_name}-file-psc"
    private_connection_resource_id = azurerm_storage_account.ai.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  private_dns_zone_group {
    name                 = "storage-file-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_file.id]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "storage_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.ai.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_file" {
  name                  = "storage-file-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_file.name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_file_hub" {
  count                 = var.enable_vnet_peering ? 1 : 0
  name                  = "storage-file-hub-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_file.name
  virtual_network_id    = data.azurerm_virtual_network.hub[0].id
  registration_enabled  = false
  tags                  = var.tags
}

# ──────────────────────────────────────────────
# Azure Container Registry (optional)
# ──────────────────────────────────────────────

resource "azurerm_container_registry" "ai" {
  count                         = var.enable_container_registry ? 1 : 0
  name                          = var.container_registry_name
  location                      = azurerm_resource_group.ai.location
  resource_group_name           = azurerm_resource_group.ai.name
  sku                           = var.container_registry_sku
  admin_enabled                 = false
  public_network_access_enabled = false

  tags = var.tags
}

resource "azurerm_private_endpoint" "acr" {
  count               = var.enable_container_registry ? 1 : 0
  name                = "${var.container_registry_name}-pe"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  subnet_id           = module.virtual_network.subnets["privateendpoint"].resource_id

  private_service_connection {
    name                           = "${var.container_registry_name}-psc"
    private_connection_resource_id = azurerm_container_registry.ai[0].id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "acr-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr[0].id]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "acr" {
  count               = var.enable_container_registry ? 1 : 0
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.ai.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  count                 = var.enable_container_registry ? 1 : 0
  name                  = "acr-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.acr[0].name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}

# ──────────────────────────────────────────────
# Azure AI Services (multi-service Cognitive account)
# ──────────────────────────────────────────────

resource "random_string" "ai_services_suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_cognitive_account" "ai_services" {
  name                          = "${var.ai_services_name}-${random_string.ai_services_suffix.result}"
  location                      = azurerm_resource_group.ai.location
  resource_group_name           = azurerm_resource_group.ai.name
  kind                          = "AIServices"
  sku_name                      = var.ai_services_sku
  custom_subdomain_name         = "${var.ai_services_name}-${random_string.ai_services_suffix.result}"
  public_network_access_enabled = var.ai_services_public_network_access

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# OpenAI Model Deployments
resource "azurerm_cognitive_deployment" "openai" {
  for_each             = var.openai_deployments
  name                 = each.key
  cognitive_account_id = azurerm_cognitive_account.ai_services.id

  model {
    format  = "OpenAI"
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = each.value.sku_name
    capacity = each.value.sku_capacity
  }
}

# Private Endpoint for AI Services
resource "azurerm_private_endpoint" "ai_services" {
  name                = "${var.ai_services_name}-pe"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  subnet_id           = module.virtual_network.subnets["privateendpoint"].resource_id

  private_service_connection {
    name                           = "${var.ai_services_name}-psc"
    private_connection_resource_id = azurerm_cognitive_account.ai_services.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name = "ai-services-dns"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.cognitive.id,
      azurerm_private_dns_zone.openai.id,
    ]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "cognitive" {
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = azurerm_resource_group.ai.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "cognitive" {
  name                  = "cognitive-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.cognitive.name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "cognitive_hub" {
  count                 = var.enable_vnet_peering ? 1 : 0
  name                  = "cognitive-hub-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.cognitive.name
  virtual_network_id    = data.azurerm_virtual_network.hub[0].id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone" "openai" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = azurerm_resource_group.ai.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai" {
  name                  = "openai-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.openai.name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai_hub" {
  count                 = var.enable_vnet_peering ? 1 : 0
  name                  = "openai-hub-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.openai.name
  virtual_network_id    = data.azurerm_virtual_network.hub[0].id
  registration_enabled  = false
  tags                  = var.tags
}

# ──────────────────────────────────────────────
# Application Insights + Log Analytics (for AI hub)
# ──────────────────────────────────────────────

resource "azurerm_log_analytics_workspace" "ai" {
  name                = "log-${var.ai_hub_name}"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "ai" {
  name                = "appi-${var.ai_hub_name}"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.ai.id
  tags                = var.tags
}

# ──────────────────────────────────────────────
# Azure AI Foundry Hub
# ──────────────────────────────────────────────

resource "azurerm_ai_foundry" "hub" {
  name                    = var.ai_hub_name
  location                = azurerm_resource_group.ai.location
  resource_group_name     = azurerm_resource_group.ai.name
  storage_account_id      = azurerm_storage_account.ai.id
  key_vault_id            = data.azurerm_key_vault.hub.id
  public_network_access   = var.ai_hub_public_network_access
  friendly_name           = var.ai_hub_display_name
  description             = var.ai_hub_description
  application_insights_id = azurerm_application_insights.ai.id
  container_registry_id   = var.enable_container_registry ? azurerm_container_registry.ai[0].id : null

  identity {
    type = "SystemAssigned"
  }

  managed_network {
    isolation_mode = "AllowOnlyApprovedOutbound"
  }

  tags = var.tags

  depends_on = [
    azurerm_private_endpoint.storage_blob,
    azurerm_private_endpoint.storage_file,
    azurerm_private_endpoint.ai_services,
  ]
}

# Private Endpoint for AI Foundry Hub
resource "azurerm_private_endpoint" "ai_hub" {
  name                = "${var.ai_hub_name}-pe"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  subnet_id           = module.virtual_network.subnets["privateendpoint"].resource_id

  private_service_connection {
    name                           = "${var.ai_hub_name}-psc"
    private_connection_resource_id = azurerm_ai_foundry.hub.id
    is_manual_connection           = false
    subresource_names              = ["amlworkspace"]
  }

  private_dns_zone_group {
    name = "ai-hub-dns"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.ml_api.id,
      azurerm_private_dns_zone.ml_notebooks.id,
    ]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "ml_api" {
  name                = "privatelink.api.azureml.ms"
  resource_group_name = azurerm_resource_group.ai.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "ml_api" {
  name                  = "ml-api-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.ml_api.name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "ml_api_hub" {
  count                 = var.enable_vnet_peering ? 1 : 0
  name                  = "ml-api-hub-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.ml_api.name
  virtual_network_id    = data.azurerm_virtual_network.hub[0].id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone" "ml_notebooks" {
  name                = "privatelink.notebooks.azure.net"
  resource_group_name = azurerm_resource_group.ai.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "ml_notebooks" {
  name                  = "ml-notebooks-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.ml_notebooks.name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "ml_notebooks_hub" {
  count                 = var.enable_vnet_peering ? 1 : 0
  name                  = "ml-notebooks-hub-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.ml_notebooks.name
  virtual_network_id    = data.azurerm_virtual_network.hub[0].id
  registration_enabled  = false
  tags                  = var.tags
}

# ──────────────────────────────────────────────
# AI Hub ↔ AI Services Connection
# ──────────────────────────────────────────────

resource "azurerm_ai_foundry_project" "project" {
  name               = var.ai_project_name
  location           = azurerm_resource_group.ai.location
  ai_services_hub_id = azurerm_ai_foundry.hub.id
  friendly_name      = var.ai_project_display_name

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Connect AI Services to the AI Hub using azapi (the native connection resource)
resource "azapi_resource" "ai_services_connection" {
  type      = "Microsoft.MachineLearningServices/workspaces/connections@2024-10-01"
  name      = "ais-${var.ai_services_name}"
  parent_id = azurerm_ai_foundry.hub.id

  body = {
    properties = {
      category      = "AIServices"
      target        = azurerm_cognitive_account.ai_services.endpoint
      authType      = "AAD"
      isSharedToAll = true
      metadata = {
        ApiType    = "Azure"
        ResourceId = azurerm_cognitive_account.ai_services.id
      }
    }
  }
}

# ──────────────────────────────────────────────
# Azure SQL Database Connection (PaaS workload)
# ──────────────────────────────────────────────
# Creates a private endpoint from the AI Foundry VNet to the
# PaaS Azure SQL Server so prompt flows / agents can query SQL.

data "azurerm_mssql_server" "paas" {
  count               = var.enable_paas_sql_connection ? 1 : 0
  name                = var.paas_sql_server_name
  resource_group_name = var.paas_sql_server_resource_group
}

resource "azurerm_private_endpoint" "paas_sql" {
  count               = var.enable_paas_sql_connection ? 1 : 0
  name                = "${var.paas_sql_server_name}-ai-pe"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  subnet_id           = module.virtual_network.subnets["privateendpoint"].resource_id

  private_service_connection {
    name                           = "${var.paas_sql_server_name}-ai-psc"
    private_connection_resource_id = data.azurerm_mssql_server.paas[0].id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-ai-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql[0].id]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "sql" {
  count               = var.enable_paas_sql_connection ? 1 : 0
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.ai.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  count                 = var.enable_paas_sql_connection ? 1 : 0
  name                  = "sql-ai-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.sql[0].name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_hub" {
  count                 = var.enable_paas_sql_connection && var.enable_vnet_peering ? 1 : 0
  name                  = "sql-hub-dns-link"
  resource_group_name   = azurerm_resource_group.ai.name
  private_dns_zone_name = azurerm_private_dns_zone.sql[0].name
  virtual_network_id    = data.azurerm_virtual_network.hub[0].id
  registration_enabled  = false
  tags                  = var.tags
}

# Store PaaS SQL connection info as a hub connection for prompt flow usage
resource "azapi_resource" "sql_connection" {
  count     = var.enable_paas_sql_connection ? 1 : 0
  type      = "Microsoft.MachineLearningServices/workspaces/connections@2024-10-01"
  name      = "sql-${var.paas_sql_server_name}"
  parent_id = azurerm_ai_foundry.hub.id

  body = {
    properties = {
      category      = "CustomKeys"
      target        = "${var.paas_sql_server_name}.database.windows.net"
      authType      = "CustomKeys"
      isSharedToAll = true
      credentials = {
        keys = {
          server   = "${var.paas_sql_server_name}.database.windows.net"
          database = var.paas_sql_database_name
          driver   = "ODBC Driver 18 for SQL Server"
        }
      }
      metadata = {
        type        = "AzureSqlDatabase"
        ResourceId  = var.enable_paas_sql_connection ? data.azurerm_mssql_server.paas[0].id : ""
        description = "Azure SQL Database connection for PaaS workload"
      }
    }
  }
}

# ──────────────────────────────────────────────
# IaaS SQL VM Connection (via Private Link Service)
# ──────────────────────────────────────────────
# Connects to the PLS deployed in iaas-app that fronts the SQL Server VM.
# The PLS must be created first (see iaas-app module).

resource "azurerm_private_endpoint" "iaas_sql" {
  count               = var.enable_iaas_sql_pls ? 1 : 0
  name                = "iaas-sql-ai-pe"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  subnet_id           = module.virtual_network.subnets["privateendpoint"].resource_id

  private_service_connection {
    name                           = "iaas-sql-ai-psc"
    private_connection_resource_id = var.iaas_sql_private_link_service_id
    is_manual_connection           = false
  }

  tags = var.tags
}

# ──────────────────────────────────────────────
# Key Vault Private DNS Zone Link
# ──────────────────────────────────────────────

data "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.hub_resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_ai" {
  name                  = "kv-ai-link"
  resource_group_name   = var.hub_resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}

# ──────────────────────────────────────────────
# VNet Peering
# ──────────────────────────────────────────────

data "azurerm_virtual_network" "hub" {
  count               = var.enable_vnet_peering ? 1 : 0
  name                = var.hub_vnet_name
  resource_group_name = var.hub_vnet_resource_group
}

# AI to Hub
resource "azurerm_virtual_network_peering" "ai_to_hub" {
  count                     = var.enable_vnet_peering ? 1 : 0
  name                      = "peer-ai-to-hub"
  resource_group_name       = azurerm_resource_group.ai.name
  virtual_network_name      = module.virtual_network.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub[0].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Hub to AI
resource "azurerm_virtual_network_peering" "hub_to_ai" {
  count                     = var.enable_vnet_peering ? 1 : 0
  name                      = "peer-hub-to-ai"
  resource_group_name       = var.hub_vnet_resource_group
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = module.virtual_network.resource_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# ──────────────────────────────────────────────
# RBAC: AI Hub identity → Key Vault Secrets User
# ──────────────────────────────────────────────

resource "azurerm_role_assignment" "ai_hub_kv_secrets" {
  scope                = data.azurerm_key_vault.hub.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_ai_foundry.hub.identity[0].principal_id
}

# NOTE: Storage Blob Data Contributor for AI Hub and AI Project identities
# are auto-provisioned by Azure AI Foundry and do not need to be managed here.

# RBAC: AI Project identity → Cognitive Services OpenAI User
resource "azurerm_role_assignment" "ai_project_openai" {
  scope                = azurerm_cognitive_account.ai_services.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_ai_foundry_project.project.identity[0].principal_id
}
