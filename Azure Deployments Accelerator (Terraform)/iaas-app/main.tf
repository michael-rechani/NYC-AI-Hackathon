# Resource Group
resource "azurerm_resource_group" "iaas" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ──────────────────────────────────────────────
# Networking
# ──────────────────────────────────────────────

# NSG for Web Tier
resource "azurerm_network_security_group" "web" {
  name                = "${var.web_vm_name}-nsg"
  location            = azurerm_resource_group.iaas.location
  resource_group_name = azurerm_resource_group.iaas.name
  tags                = var.tags

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowRDPFromHubJumpbox"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.hub_jumpbox_subnet_prefix
    destination_address_prefix = "*"
  }
}

# NSG for Data Tier
resource "azurerm_network_security_group" "data" {
  name                = "${var.sql_vm_name}-nsg"
  location            = azurerm_resource_group.iaas.location
  resource_group_name = azurerm_resource_group.iaas.name
  tags                = var.tags

  security_rule {
    name                       = "AllowSQLFromWeb"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = var.web_subnet_prefix
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSQLFromPaaS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = var.paas_app_subnet_prefix
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowRDPFromHubJumpbox"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.hub_jumpbox_subnet_prefix
    destination_address_prefix = "*"
  }
}

# Virtual Network (AVM)
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1"

  parent_id     = azurerm_resource_group.iaas.id
  location      = azurerm_resource_group.iaas.location
  name          = var.vnet_name
  address_space = var.vnet_address_space

  tags = var.tags

  subnets = {
    web = {
      name                            = "web-subnet"
      address_prefixes                = [var.web_subnet_prefix]
      default_outbound_access_enabled = false
      network_security_group = {
        id = azurerm_network_security_group.web.id
      }
      nat_gateway = {
        id = azurerm_nat_gateway.iaas.id
      }
      service_endpoints_with_location = [{ service = "Microsoft.KeyVault" }]
    }
    data = {
      name                            = "data-subnet"
      address_prefixes                = [var.data_subnet_prefix]
      default_outbound_access_enabled = false
      network_security_group = {
        id = azurerm_network_security_group.data.id
      }
      nat_gateway = {
        id = azurerm_nat_gateway.iaas.id
      }
      service_endpoints_with_location = [{ service = "Microsoft.KeyVault" }]
    }
  }

  depends_on = [
    azurerm_network_security_group.web,
    azurerm_network_security_group.data
  ]
}

# NAT Gateway for web/data subnets
resource "azurerm_public_ip" "nat_gateway" {
  name                = "pip-${var.vnet_name}-nat"
  location            = azurerm_resource_group.iaas.location
  resource_group_name = azurerm_resource_group.iaas.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "iaas" {
  name                = "nat-${var.vnet_name}"
  location            = azurerm_resource_group.iaas.location
  resource_group_name = azurerm_resource_group.iaas.name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "iaas" {
  nat_gateway_id       = azurerm_nat_gateway.iaas.id
  public_ip_address_id = azurerm_public_ip.nat_gateway.id
}

# ──────────────────────────────────────────────
# Hub Key Vault reference
# ──────────────────────────────────────────────

data "azurerm_key_vault" "hub" {
  name                = var.hub_key_vault_name
  resource_group_name = coalesce(var.hub_key_vault_resource_group, var.hub_resource_group_name)
}

# ──────────────────────────────────────────────
# Web VM (AVM)
# ──────────────────────────────────────────────

module "web_vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.20.0"

  name                = var.web_vm_name
  location            = azurerm_resource_group.iaas.location
  resource_group_name = azurerm_resource_group.iaas.name
  zone                = var.web_vm_zone

  os_type      = "Windows"
  sku_size     = var.web_vm_size
  license_type = "Windows_Server"

  source_image_reference = var.web_image

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  encryption_at_host_enabled = false

  network_interfaces = {
    nic0 = {
      name = "${var.web_vm_name}-nic"
      ip_configurations = {
        ipconfig1 = {
          name                          = "internal"
          private_ip_subnet_resource_id = module.virtual_network.subnets["web"].resource_id
        }
      }
    }
  }

  managed_identities = {
    system_assigned = true
  }

  tags = var.tags

  depends_on = [module.virtual_network]
}

# Store Web VM credentials in Hub Key Vault
resource "azurerm_key_vault_secret" "web_admin_username" {
  name         = "iaas-web-admin-username"
  value        = module.web_vm.admin_username
  key_vault_id = data.azurerm_key_vault.hub.id
  content_type = "text/plain"
  tags         = var.tags
}

resource "azurerm_key_vault_secret" "web_admin_password" {
  name         = "iaas-web-admin-password"
  value        = module.web_vm.admin_password
  key_vault_id = data.azurerm_key_vault.hub.id
  content_type = "text/plain"
  tags         = var.tags
}

# ──────────────────────────────────────────────
# SQL VM (AVM)
# ──────────────────────────────────────────────

module "sql_vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.20.0"

  name                = var.sql_vm_name
  location            = azurerm_resource_group.iaas.location
  resource_group_name = azurerm_resource_group.iaas.name
  zone                = var.sql_vm_zone

  os_type      = "Windows"
  sku_size     = var.sql_vm_size
  license_type = "Windows_Server"

  source_image_reference = var.sql_image

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  encryption_at_host_enabled = false

  network_interfaces = {
    nic0 = {
      name = "${var.sql_vm_name}-nic"
      ip_configurations = {
        ipconfig1 = {
          name                          = "internal"
          private_ip_subnet_resource_id = module.virtual_network.subnets["data"].resource_id
        }
      }
    }
  }

  data_disk_managed_disks = {
    data = {
      name                 = "${var.sql_vm_name}-datadisk"
      storage_account_type = "Premium_LRS"
      lun                  = 0
      caching              = "ReadOnly"
      disk_size_gb         = var.sql_data_disk_size_gb
    }
    log = {
      name                 = "${var.sql_vm_name}-logdisk"
      storage_account_type = "Premium_LRS"
      lun                  = 1
      caching              = "None"
      disk_size_gb         = var.sql_log_disk_size_gb
    }
  }

  managed_identities = {
    system_assigned = true
  }

  tags = var.tags

  depends_on = [module.virtual_network]
}

# Store SQL VM credentials in Hub Key Vault
resource "azurerm_key_vault_secret" "sql_admin_username" {
  name         = "iaas-sql-admin-username"
  value        = module.sql_vm.admin_username
  key_vault_id = data.azurerm_key_vault.hub.id
  content_type = "text/plain"
  tags         = var.tags
}

resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "iaas-sql-admin-password"
  value        = module.sql_vm.admin_password
  key_vault_id = data.azurerm_key_vault.hub.id
  content_type = "text/plain"
  tags         = var.tags
}

# SQL IaaS Extension
resource "azurerm_mssql_virtual_machine" "sql" {
  virtual_machine_id    = module.sql_vm.resource_id
  sql_license_type      = var.sql_license_type
  sql_connectivity_type = "PRIVATE"
  tags                  = var.tags
}

# ──────────────────────────────────────────────
# Key Vault Private DNS Zone Link
# ──────────────────────────────────────────────

data "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.hub_resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_iaas" {
  name                  = "kv-iaas-link"
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
  name                = var.hub_vnet_name
  resource_group_name = var.hub_resource_group_name
}

# IaaS to Hub
resource "azurerm_virtual_network_peering" "iaas_to_hub" {
  name                      = "peer-iaas-to-hub"
  resource_group_name       = azurerm_resource_group.iaas.name
  virtual_network_name      = module.virtual_network.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Hub to IaaS
resource "azurerm_virtual_network_peering" "hub_to_iaas" {
  name                      = "peer-hub-to-iaas"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = module.virtual_network.resource_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
