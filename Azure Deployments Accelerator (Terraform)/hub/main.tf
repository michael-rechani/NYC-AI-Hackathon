# Resource Group
resource "azurerm_resource_group" "hub" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ──────────────────────────────────────────────
# Networking
# ──────────────────────────────────────────────

# NSG for Jumpbox
resource "azurerm_network_security_group" "jumpbox" {
  name                = "${var.jumpbox_name}-nsg"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags

  security_rule {
    name                       = "AllowBastionToJumpbox"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.bastion_subnet_prefix
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowJumpboxToVNet"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowJumpboxToAzureCloud"
    priority                   = 210
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  security_rule {
    name                       = "AllowJumpboxToInternet"
    priority                   = 220
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

# Virtual Network (AVM)
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1"

  parent_id     = azurerm_resource_group.hub.id
  location      = azurerm_resource_group.hub.location
  name          = var.vnet_name
  address_space = var.vnet_address_space

  tags = var.tags

  subnets = {
    bastion = {
      name                            = "AzureBastionSubnet"
      address_prefixes                = [var.bastion_subnet_prefix]
      default_outbound_access_enabled = false
    }
    jumpbox = {
      name                            = "jumpbox-subnet"
      address_prefixes                = [var.jumpbox_subnet_prefix]
      default_outbound_access_enabled = false
      network_security_group = {
        id = azurerm_network_security_group.jumpbox.id
      }
      nat_gateway = {
        id = azurerm_nat_gateway.hub.id
      }
    }
    privateendpoint = {
      name                              = "privateendpoint-subnet"
      address_prefixes                  = [var.privateendpoint_subnet_prefix]
      default_outbound_access_enabled   = false
      private_endpoint_network_policies = "Disabled"
    }
  }

  depends_on = [azurerm_network_security_group.jumpbox]
}

# NAT Gateway for jumpbox subnet
resource "azurerm_public_ip" "nat_gateway" {
  name                = "pip-${var.vnet_name}-nat"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "hub" {
  name                = "nat-${var.vnet_name}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "hub" {
  nat_gateway_id       = azurerm_nat_gateway.hub.id
  public_ip_address_id = azurerm_public_ip.nat_gateway.id
}

# ──────────────────────────────────────────────
# Azure Bastion (AVM)
# ──────────────────────────────────────────────

module "bastion" {
  source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "0.9.0"

  name      = var.bastion_name
  location  = azurerm_resource_group.hub.location
  parent_id = azurerm_resource_group.hub.id

  sku = var.bastion_sku

  ip_configuration = {
    name                   = "bastion-ipconfig"
    subnet_id              = module.virtual_network.subnets["bastion"].resource_id
    create_public_ip       = true
    public_ip_address_name = "pip-${var.bastion_name}"
  }

  ip_connect_enabled = var.bastion_sku == "Standard" || var.bastion_sku == "Premium" ? true : false
  tunneling_enabled  = var.bastion_sku == "Standard" || var.bastion_sku == "Premium" ? true : false

  tags = var.tags

  depends_on = [module.virtual_network]
}

# ──────────────────────────────────────────────
# Jumpbox VM (AVM)
# ──────────────────────────────────────────────

module "jumpbox" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.20.0"

  name                = var.jumpbox_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  zone                = var.jumpbox_zone

  os_type      = "Windows"
  sku_size     = var.jumpbox_vm_size
  license_type = "Windows_Server"

  source_image_reference = var.jumpbox_image

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  encryption_at_host_enabled = false

  network_interfaces = {
    nic0 = {
      name = "${var.jumpbox_name}-nic"
      ip_configurations = {
        ipconfig1 = {
          name                          = "internal"
          private_ip_subnet_resource_id = module.virtual_network.subnets["jumpbox"].resource_id
        }
      }
    }
  }

  tags = var.tags

  depends_on = [module.virtual_network]
}

# ──────────────────────────────────────────────
# Key Vault (AVM)
# ──────────────────────────────────────────────

data "azurerm_client_config" "current" {}

# Auto-detect the Terraform executor's public IP for Key Vault firewall
data "http" "my_ip" {
  url = "https://api.ipify.org"
}

module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.2"

  name                = var.key_vault_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                      = var.key_vault_sku
  purge_protection_enabled      = var.key_vault_purge_protection
  soft_delete_retention_days    = var.key_vault_soft_delete_days
  public_network_access_enabled = true

  enabled_for_deployment          = false
  enabled_for_template_deployment = true
  enabled_for_disk_encryption     = false

  # Use legacy access policies for compatibility
  legacy_access_policies_enabled = true
  legacy_access_policies = {
    admin = {
      object_id          = data.azurerm_client_config.current.object_id
      key_permissions    = ["Get", "List", "Create", "Delete"]
      secret_permissions = ["Get", "List", "Set", "Delete"]
    }
  }

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = concat(["${chomp(data.http.my_ip.response_body)}/32"], var.key_vault_allowed_ips)
  }

  # Private Endpoint for Key Vault
  private_endpoints = {
    pe = {
      subnet_resource_id            = module.virtual_network.subnets["privateendpoint"].resource_id
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.key_vault.id]
    }
  }

  tags = var.tags

  depends_on = [module.virtual_network]
}

# Store jumpbox credentials in Key Vault
resource "azurerm_key_vault_secret" "jumpbox_admin_username" {
  name         = "hub-jumpbox-admin-username"
  value        = module.jumpbox.admin_username
  key_vault_id = module.key_vault.resource_id
  tags         = var.tags

  depends_on = [module.key_vault]
}

resource "azurerm_key_vault_secret" "jumpbox_admin_password" {
  name         = "hub-jumpbox-admin-password"
  value        = module.jumpbox.admin_password
  key_vault_id = module.key_vault.resource_id
  tags         = var.tags

  depends_on = [module.key_vault]
}

# ──────────────────────────────────────────────
# Private DNS Zone for Key Vault
# ──────────────────────────────────────────────

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags
}

# Link to hub VNet
resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_hub" {
  name                  = "kv-hub-link"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = module.virtual_network.resource_id
  registration_enabled  = false
  tags                  = var.tags
}


