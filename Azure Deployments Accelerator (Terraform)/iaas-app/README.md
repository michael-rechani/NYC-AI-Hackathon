# IaaS Deployment (Web and SQL VMs)

This module deploys Azure IaaS infrastructure for a multi-tier application including:

- Virtual Network with web and data subnets
- Windows Web Server VM
- SQL Server VM with optimized storage configuration
- Network Security Groups with tier-appropriate rules
- NAT Gateway for outbound internet access
- VNet Peering to hub network
- Private DNS Zone link to hub's Key Vault DNS zone
- Optional public IP for web access

> **Prerequisite**: The [hub](../hub/README.md) layer must be deployed first. This module references the hub's Key Vault (for storing credentials) and Private DNS Zone (for Key Vault private connectivity).

## Prerequisites

- Azure subscription
- Terraform >= 1.10.0
- Azure CLI authenticated
- **Hub infrastructure deployed** (provides Key Vault and DNS zone)

## Usage

<!-- markdownlint-disable MD029 -->

1. Edit `terraform.tfvars` with your desired values (sample values are already provided)
2. Ensure `hub_resource_group_name`, `hub_vnet_name`, and `hub_key_vault_name` match your hub deployment

3. Initialize Terraform:

  ```bash
  terraform init
  ```

4. Plan the deployment:

  ```bash
  terraform plan
  ```

5. Apply the configuration:

  ```bash
  terraform apply
  ```

<!-- markdownlint-enable MD029 -->

## Resources Created

- Resource Group
- Virtual Network with 2 subnets:
  - web-subnet (for web tier)
  - data-subnet (for database tier)
- Web Server VM (Windows Server 2022)
- SQL Server VM (SQL Server 2022 on Windows Server 2022)
- NAT Gateway with public IP (for web and data subnet outbound access)
- VNet Peering (bidirectional) to hub VNet
- Private DNS Zone link to hub's `privatelink.vaultcore.azure.net` zone
- Network Security Groups with appropriate rules:
  - Web tier: HTTP (80), HTTPS (443)
  - Data tier: SQL (1433) from web subnet only
- Managed Disks for SQL data and log files
- Optional Public IP for web access

### Important Notes

- **VM Name Length**: Windows computer names must be 15 characters or fewer. Keep `web_vm_name` and `sql_vm_name` within this limit.
- **EncryptionAtHost**: If your subscription does not have the `Microsoft.Compute/EncryptionAtHost` feature registered, `encryption_at_host_enabled` is set to `false`.

## SQL Server Configuration

The SQL VM is configured with:

- Separate data and log disks for optimal performance
- SQL IaaS Agent Extension for management
- Optimized storage configuration
- License type configuration (PAYG by default)

## Outputs

After deployment, review outputs and retrieve credentials from the Hub Key Vault:

```bash
# Example outputs
terraform output web_vm_name
terraform output sql_vm_name

# Retrieve credentials from the Hub Key Vault
cd ../hub
KV_NAME=$(terraform output -raw key_vault_name)
cd ../iaas-app
az keyvault secret show --vault-name $KV_NAME --name iaas-web-admin-username --query value -o tsv
az keyvault secret show --vault-name $KV_NAME --name iaas-web-admin-password --query value -o tsv
az keyvault secret show --vault-name $KV_NAME --name iaas-sql-admin-username --query value -o tsv
az keyvault secret show --vault-name $KV_NAME --name iaas-sql-admin-password --query value -o tsv
```

## Azure Verified Modules Used

- [Virtual Network](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest)
- [Virtual Machine](https://registry.terraform.io/modules/Azure/avm-res-compute-virtualmachine/azurerm/latest)

## Next Steps

After deployment:

1. Connect to the web VM via Bastion (from hub) or public IP
2. Install and configure IIS or your web application
3. Configure SQL Server databases and security
4. Set up connectivity between web and SQL tiers
