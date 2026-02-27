# IaaS Deployment (Web and SQL VMs)

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)
![Microsoft Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?logo=microsoftazure&logoColor=white)
![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=githubcopilot&logoColor=white)

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

## 🤖 Use GitHub Copilot

Open this folder in VS Code, switch Copilot Chat to **Agent mode**, and paste the prompt below.

<details>
<summary><strong>View Copilot prompt</strong></summary>

```text
You are a senior Azure infrastructure engineer. The existing Terraform configuration
in this folder deploys an IaaS landing zone: a Windows Server 2022 web VM, a
SQL Server 2022 VM, network segmentation (web and data subnets), NSG rules, and
VNet peering to the hub.

PREREQUISITE
The hub/ module must already be deployed. You will need the hub's output values:
- hub_resource_group_name
- hub_vnet_name
- hub_key_vault_name
Run `cd ../hub && terraform output` to retrieve them if needed.

TASK
Review the existing Terraform files and help me:

1. Explain how this IaaS layer connects to the hub and why the VNet peering
   and Private DNS Zone link are needed.

2. Walk me through terraform.tfvars — identify every value I must update,
   especially the three hub cross-references listed above.

3. Guide me step-by-step through terraform init, terraform plan, and
   terraform apply.

4. After deployment, show me how to connect to the web VM via Azure Bastion.

5. Show me where the web and SQL VM credentials are stored (hint: Hub Key Vault)
   and how to retrieve them with the Azure CLI.

6. Help me troubleshoot any errors that appear during plan or apply.

CONSTRAINTS
- Use the existing .tf files as-is. Do not rewrite them.
- Do not make changes to any file unless I explicitly ask.
```

</details>

---

## ⚡ Get Started

> **Prerequisite**: The [hub](../hub/README.md) module must be deployed first. You will need its `hub_resource_group_name`, `hub_vnet_name`, and `hub_key_vault_name` output values for `terraform.tfvars`.

Your Windows 365 desktop includes Terraform and Azure CLI. Verify your environment by opening VS Code, switching Copilot Chat to **Agent mode**, and pasting:

```text
Check my environment for deploying this Terraform module:

1. Verify these tools are installed and show the version:
   - Terraform: run `terraform version` (must be >= 1.10.0)
   - Azure CLI: run `az --version`

2. Run `az account show` — confirm I am logged in and show me the active subscription name and ID.

3. If anything is missing, install or fix it now.
```

Then use the Copilot prompt above — it will walk you through the hub cross-references in `terraform.tfvars`, run `terraform init`, `terraform plan`, and `terraform apply`, and help you connect to VMs via Bastion and retrieve credentials from Key Vault.

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
