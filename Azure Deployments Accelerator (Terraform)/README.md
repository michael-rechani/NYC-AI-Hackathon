# Azure Deployments Accelerator

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)
![Microsoft Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?logo=microsoftazure&logoColor=white)
![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=githubcopilot&logoColor=white)

Infrastructure as Code to deploy support infrastructure and Azure resources to host multi-tier applications using Terraform and Azure Verified Modules.

## 🤖 Using GitHub Copilot with This Accelerator

The Terraform modules in this accelerator are pre-built and ready to deploy — but GitHub Copilot can help you understand the code, customize variables for your environment, and troubleshoot any issues during deployment.

**How to use Copilot with any module:**

1. Open the module folder (e.g., `hub/`) in VS Code
2. Switch Copilot Chat to **Agent mode**
3. Paste the Copilot prompt from that module's README into the chat
4. Copilot will read your `.tf` files and guide you through configuration and deployment

Each module README below includes a **"Use GitHub Copilot"** section with a ready-to-paste prompt.

---

## 📋 Overview

This repository provides a hub-and-spoke deployment model for Azure infrastructure:

1. **Hub Infrastructure** (deploy first) - Core networking with VNet, Azure Bastion, Jumpbox, Key Vault, and Private DNS
2. **IaaS Deployment** (requires hub) - Virtual Machine-based web and SQL servers with VNet peering to hub
3. **PaaS Deployment** (requires hub) - App Service and Azure SQL Database with VNet peering to hub

All deployments utilize [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/) for Terraform, ensuring best practices and maintainability.

## 📚 Documentation

- **[Deployment Guide](DEPLOYMENT.md)** - Step-by-step deployment instructions
- **[Architecture Overview](ARCHITECTURE.md)** - Detailed architecture diagrams and patterns
- **Hub** - [README](hub/README.md) for hub infrastructure
- **IaaS** - [README](iaas-app/README.md) for IaaS deployment
- **PaaS** - [README](paas-app/README.md) for PaaS deployment

## 🚀 Quick Start

### ⚡ Before You Start

Your Windows 365 desktop includes Terraform and Azure CLI. Verify your environment by opening VS Code, switching Copilot Chat to **Agent mode**, and pasting:

```text
Check my environment for deploying Terraform infrastructure on Azure:

1. Verify these tools are installed and show the version:
   - Terraform: run `terraform version` (must be >= 1.10.0)
   - Azure CLI: run `az --version`
   - Git: run `git --version`

2. Run `az account show` — confirm I am logged in and show me the active subscription name and ID.

3. If anything is missing, install or fix it now.
```

### Deployment

> **Note**: This repository includes sample `terraform.tfstate` files for workshop/demo purposes. Remove `terraform.tfstate*` and the `.terraform` directory before running your own deployments.

Deploy modules in order — **hub first**, then workload layers. For each module:

1. Open the module folder in VS Code (e.g., `hub/`)
2. Switch Copilot Chat to **Agent mode**
3. Paste the Copilot prompt from that module's README — Copilot will walk you through `terraform.tfvars`, `terraform init`, `terraform plan`, and `terraform apply`

| Step | Module | Purpose |
| --- | --- | --- |
| 1 | [hub/](hub/README.md) | Core networking, Key Vault, Bastion — deploy first |
| 2a | [iaas-app/](iaas-app/README.md) | SQL Server VM + Web VM *(optional)* |
| 2b | [paas-app/](paas-app/README.md) | App Service + Azure SQL Database *(optional)* |
| 3 | [ai-foundry/](ai-foundry/README.md) | AI Hub, GPT-4o, SQL connections *(optional)* |

## 📁 Repository Structure

```text
.
├── hub/                 # Hub infrastructure (VNet, Bastion, Jumpbox)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── README.md
├── iaas-app/           # IaaS deployment (Web and SQL VMs)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── README.md
├── paas-app/           # PaaS deployment (App Service and Azure SQL)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── README.md
├── migration-tools/    # Azure migration assessment utilities
│   ├── database-assessment/          # SQL Server → Azure SQL migration tools
│   │   ├── install-azure-data-studio.ps1
│   │   ├── install-azure-dms-module.ps1
│   │   ├── run-dms-assessment.ps1
│   │   ├── setup-azure-dms.ps1
│   │   └── README.md
│   ├── server-assessment/            # IIS apps and servers → Azure App Service / Azure Migrate
│   │   ├── install-app-service-migration-assistant.ps1
│   │   ├── install-azure-migrate-agent.ps1
│   │   ├── setup-azure-migrate.ps1
│   │   └── README.md
│   └── README.md
├── DEPLOYMENT.md       # Detailed deployment guide
├── ARCHITECTURE.md     # Architecture diagrams and patterns
└── README.md          # This file
```

## ⚙️ Deployment Options

### Step 1: Hub Infrastructure (Deploy First)

Open `hub/` in VS Code, switch Copilot Chat to **Agent mode**, and use the [Copilot prompt in hub/README.md](hub/README.md). Copilot will guide you through configuration and deployment.

**Resources Created:**

- Virtual Network with subnets (Bastion, Jumpbox, Private Endpoint)
- Azure Bastion for secure RDP/SSH access
- Windows Server 2022 Jumpbox VM
- NAT Gateway for outbound internet access
- Azure Key Vault with Private Endpoint (centralized secrets)
- Private DNS Zone (`privatelink.vaultcore.azure.net`)
- Network Security Groups

### Step 2a: IaaS Deployment (Requires Hub)

Open `iaas-app/` in VS Code, switch Copilot Chat to **Agent mode**, and use the [Copilot prompt in iaas-app/README.md](iaas-app/README.md).

**Resources Created:**

- Virtual Network with web and data subnets
- Windows Web Server VM
- SQL Server 2022 VM with optimized storage
- NAT Gateway for outbound internet access
- VNet Peering to hub network
- Network Security Groups with tier-appropriate rules
- Optional public IP for web access

### Step 2b: PaaS Deployment (Requires Hub)

Open `paas-app/` in VS Code, switch Copilot Chat to **Agent mode**, and use the [Copilot prompt in paas-app/README.md](paas-app/README.md).

**Resources Created:**

- App Service Plan and App Service with Private Endpoint
- Azure SQL Server and Database with Private Endpoint
- Virtual Network with VNet integration
- NAT Gateway for outbound internet access
- VNet Peering to hub network
- Application Insights

## 🔧 Azure Verified Modules

This repository uses the following Azure Verified Modules:

- [Virtual Network](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest) - Virtual networking
- [Bastion Host](https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/azurerm/latest) - Secure remote access
- [Virtual Machine](https://registry.terraform.io/modules/Azure/avm-res-compute-virtualmachine/azurerm/latest) - IaaS compute
- [Key Vault](https://registry.terraform.io/modules/Azure/avm-res-keyvault-vault/azurerm/latest) - Centralized secrets management
- [App Service Plan](https://registry.terraform.io/modules/Azure/avm-res-web-serverfarm/azurerm/latest) - PaaS hosting plan
- [SQL Server](https://registry.terraform.io/modules/Azure/avm-res-sql-server/azurerm/latest) - Managed database service

## 🎯 Deployment Scenarios

### Scenario 1: Hub + IaaS (Lift & Shift)

Deploy `hub/` → then `iaas-app/`. Use the Copilot prompt in each module's README to guide deployment.

### Scenario 2: Hub + PaaS (Cloud-Native)

Deploy `hub/` → then `paas-app/`. Use the Copilot prompt in each module's README to guide deployment.

### Scenario 3: Complete Environment (Hub + IaaS + PaaS)

Deploy `hub/` → `iaas-app/` → `paas-app/` → optionally `ai-foundry/`. Use the Copilot prompt in each module's README at each step.

> **Note**: Hub must always be deployed first. IaaS, PaaS, and AI Foundry layers can be deployed in any order after hub.

## 💡 Best Practices

1. **Resource Naming**: Follow Azure naming conventions with environment prefixes
2. **Tagging**: Use consistent tags for cost tracking and resource management
3. **Security**:
   - Use private endpoints for PaaS services in production
   - Implement Network Security Groups for IaaS deployments
   - Enable Azure Bastion for secure VM access
4. **State Management**: Use remote state storage (Azure Storage Account) for team environments
5. **Secrets**: Never commit `terraform.tfvars` files with sensitive data to version control

## 💰 Cost Optimization

- Use **Basic** or **Standard** SKUs for development/test environments
- Enable auto-pause for serverless SQL databases
- Use **Burstable** VM sizes (B-series) for non-production workloads
- Implement auto-shutdown policies for development VMs
- Monitor costs with Azure Cost Management

## 🧹 Cleanup

To destroy resources and avoid ongoing charges:

```bash
# In each deployment directory
terraform destroy
```

**Note**: Destroy resources in reverse order if you have dependencies (IaaS/PaaS before Hub).

## 🤝 Contributing

Contributions are welcome! Please ensure:

- Code follows Terraform best practices
- Documentation is updated for any changes
- Use Azure Verified Modules where available

## 📞 Support

For issues and questions:

- Review module documentation in each directory's README
- Check [Deployment Guide](DEPLOYMENT.md) for troubleshooting
- Review [Architecture Guide](ARCHITECTURE.md) for design patterns
- Check [Azure Verified Modules documentation](https://azure.github.io/Azure-Verified-Modules/)
- Open an issue in this repository

## 📄 License

This project is provided as-is for educational and demonstration purposes.

---

**Note**: This workshop demonstrates Infrastructure as Code best practices using Azure Verified Modules. Customize the configurations to meet your specific requirements.
