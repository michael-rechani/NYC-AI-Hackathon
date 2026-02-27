# Hub Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)
![Microsoft Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?logo=microsoftazure&logoColor=white)
![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=githubcopilot&logoColor=white)

This module deploys the hub Azure infrastructure including:
- Virtual Network with multiple subnets
- Azure Bastion for secure remote access
- Windows Jumpbox VM
- Azure Key Vault with Private Endpoint for centralized secrets management
- NAT Gateway for outbound internet access
- Private DNS Zone for Key Vault private connectivity

> **Important**: The hub must be deployed **before** the iaas-app or paas-app layers, as they reference the hub's Key Vault and Private DNS Zone.

## 🤖 Use GitHub Copilot

Open this folder in VS Code, switch Copilot Chat to **Agent mode**, and paste the prompt below. Copilot will read your `.tf` files and guide you through configuration and deployment.

<details>
<summary><strong>View Copilot prompt</strong></summary>

```text
You are a senior Azure infrastructure engineer. The existing Terraform configuration
in this folder deploys the hub layer of a hub-and-spoke Azure architecture, including:
Virtual Network with Bastion, Jumpbox VM, Azure Key Vault with private endpoint,
NAT Gateway, and Private DNS Zone.

TASK
Review the existing Terraform files (main.tf, variables.tf, outputs.tf,
terraform.tfvars) and help me with the following:

1. Explain the overall architecture and why each resource is needed.

2. Walk me through terraform.tfvars and identify every value I need to update
   for my environment — resource group name, location, naming prefix, and any
   admin credential placeholders.

3. After I update terraform.tfvars, guide me step-by-step through:
   - terraform init
   - terraform plan  (review the output with me before applying)
   - terraform apply

4. If terraform plan or apply returns errors, help me diagnose and fix them.

5. Once deployment succeeds, show me how to read the key outputs I'll need for
   the IaaS and PaaS layers (Key Vault name, VNet name, resource group name).

CONSTRAINTS
- Use the existing .tf files as-is. Do not rewrite them.
- Do not make changes to any file unless I explicitly ask.
- Remind me to record hub outputs before moving to the next layer.
```

</details>

---

## ⚡ Get Started

Your Windows 365 desktop includes Terraform and Azure CLI. Verify your environment by opening VS Code, switching Copilot Chat to **Agent mode**, and pasting:

```text
Check my environment for deploying this Terraform module:

1. Verify these tools are installed and show the version:
   - Terraform: run `terraform version` (must be >= 1.10.0)
   - Azure CLI: run `az --version`

2. Run `az account show` — confirm I am logged in and show me the active subscription name and ID.

3. If anything is missing, install or fix it now.
```

Then use the Copilot prompt above — it will guide you through `terraform.tfvars`, `terraform init`, `terraform plan`, `terraform apply`, and retrieving the output values needed by downstream modules.

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
