# Hub Infrastructure

This module deploys the hub Azure infrastructure including:
- Virtual Network with multiple subnets
- Azure Bastion for secure remote access
- Windows Jumpbox VM
- Azure Key Vault with Private Endpoint for centralized secrets management
- NAT Gateway for outbound internet access
- Private DNS Zone for Key Vault private connectivity

> **Important**: The hub must be deployed **before** the iaas-app or paas-app layers, as they reference the hub's Key Vault and Private DNS Zone.

## Prerequisites

- Azure subscription
- Terraform >= 1.10.0
- Azure CLI authenticated

## Usage

1. Edit `terraform.tfvars` with your desired values (sample values are already provided)

2. Initialize Terraform:
```bash
terraform init
```

3. Plan the deployment:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

## Resources Created

- Resource Group
- Virtual Network with 3 subnets:
  - AzureBastionSubnet (for Azure Bastion)
  - jumpbox-subnet (for jumpbox VM)
  - privateendpoint-subnet (for Key Vault private endpoint)
- Azure Bastion (Standard SKU with tunneling and IP connect)
- Windows Server 2022 Jumpbox VM
- NAT Gateway with public IP (for jumpbox outbound access)
- Azure Key Vault with Private Endpoint (stores all VM credentials across layers)
- Private DNS Zone (`privatelink.vaultcore.azure.net`) linked to hub VNet
- Network Security Groups

### Important Notes

- **VM Name Length**: Windows computer names must be 15 characters or fewer. Keep `jumpbox_name` within this limit.
- **EncryptionAtHost**: If your subscription does not have the `Microsoft.Compute/EncryptionAtHost` feature registered, `encryption_at_host_enabled` is set to `false`. Register the feature or leave it disabled.

## Outputs

After deployment, retrieve Key Vault details and then fetch credentials from Key Vault:

```bash
# Get Key Vault name
KV_NAME=$(terraform output -raw key_vault_name)

# Retrieve jumpbox credentials
az keyvault secret show --vault-name $KV_NAME --name hub-jumpbox-admin-username --query value -o tsv
az keyvault secret show --vault-name $KV_NAME --name hub-jumpbox-admin-password --query value -o tsv
```

## Azure Verified Modules Used

- [Virtual Network](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest)
- [Bastion Host](https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/azurerm/latest)
- [Virtual Machine](https://registry.terraform.io/modules/Azure/avm-res-compute-virtualmachine/azurerm/latest)
- [Key Vault](https://registry.terraform.io/modules/Azure/avm-res-keyvault-vault/azurerm/latest)
