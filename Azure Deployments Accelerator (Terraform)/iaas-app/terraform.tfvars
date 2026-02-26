# ──────────────────────────────────────────────
# IaaS App Infrastructure - terraform.tfvars
# ──────────────────────────────────────────────
# Customize values for your deployment.
# NOTE: No secrets in this file — credentials are auto-generated and stored in Key Vault.

# Azure Subscription
subscription_id = ""

# Resource Group
resource_group_name = "rg-iaas-workshop"
location            = "eastus"

# Network
vnet_name          = "vnet-iaas-workshop"
vnet_address_space = ["10.1.0.0/16"]
web_subnet_prefix  = "10.1.1.0/24"
data_subnet_prefix = "10.1.2.0/24"

# PaaS App Service subnet (for cross-vnet SQL NSG rule)
paas_app_subnet_prefix = "10.2.1.0/24"

# Web VM
web_vm_name = "web-iaas-wkshp"
web_vm_size = "Standard_D2s_v5"
web_vm_zone = null
web_image = {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter-g2"
  version   = "latest"
}

# SQL VM
sql_vm_name           = "sql-iaas-wkshp"
sql_vm_size           = "Standard_D4s_v5"
sql_vm_zone           = null
sql_data_disk_size_gb = 256
sql_log_disk_size_gb  = 128
sql_license_type      = "PAYG"
sql_workload_type     = "GENERAL"
sql_image = {
  publisher = "MicrosoftSQLServer"
  offer     = "sql2022-ws2022"
  sku       = "standard-gen2"
  version   = "latest"
}

# Hub references (must match hub deployment)
hub_resource_group_name      = "rg-hub-workshop"
hub_vnet_name                = "vnet-hub-workshop"
hub_jumpbox_subnet_prefix    = "10.0.2.0/24"
hub_key_vault_name           = "kv-hubworkshop"
hub_key_vault_resource_group = "rg-hub-workshop"

# Tags
tags = {
  Environment = "App-&-AIAgents-Workshop"
  ManagedBy   = "Terraform"
}
