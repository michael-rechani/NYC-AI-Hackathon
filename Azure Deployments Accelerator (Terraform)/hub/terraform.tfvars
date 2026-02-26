# ──────────────────────────────────────────────
# Hub Infrastructure - terraform.tfvars
# ──────────────────────────────────────────────
# Customize values for your deployment.
# NOTE: No secrets in this file — credentials are auto-generated and stored in Key Vault.

# Azure Subscription
subscription_id = ""

# Resource Group
resource_group_name = "rg-hub-workshop"
location            = "eastus"

# Network
vnet_name                     = "vnet-hub-workshop"
vnet_address_space            = ["10.0.0.0/16"]
bastion_subnet_prefix         = "10.0.1.0/26"
jumpbox_subnet_prefix         = "10.0.2.0/24"
privateendpoint_subnet_prefix = "10.0.3.0/24"

# Bastion
bastion_name = "bastion-hub-workshop"
bastion_sku  = "Standard"

# Jumpbox VM
jumpbox_name    = "jbox-hub-wkshp"
jumpbox_vm_size = "Standard_D2s_v5"
jumpbox_zone    = null
jumpbox_image = {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter-g2"
  version   = "latest"
}

# Key Vault
key_vault_name             = "kv-hubworkshop"
key_vault_sku              = "standard"
key_vault_purge_protection = false
key_vault_soft_delete_days = 7


# Additional IPs to whitelist on Key Vault (executor IP is auto-detected)
# key_vault_allowed_ips = ["203.0.113.5/32"]

# Tags
tags = {
  Environment = "App-&-AIAgents-Workshop"
  ManagedBy   = "Terraform"
}
