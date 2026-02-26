# App-in-a-Day-Workshop

Infrastructure as Code to deploy support infrastructure and Azure resources to host multi-tier applications using Terraform and Azure Verified Modules.

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

### Prerequisites

- Azure subscription
- [Terraform](https://www.terraform.io/downloads.html) >= 1.10.0 (tested with 1.10.5)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed and authenticated
- Appropriate Azure permissions to create resources

### Basic Deployment

> **Note**: This repository includes sample `terraform.tfstate` files for workshop/demo purposes. Remove `terraform.tfstate*` and the `.terraform` directory before running your own deployments.

1. **Authenticate to Azure:**

   ```bash
   az login
   az account set --subscription "<your-subscription-id>"
   ```

2. **Deploy hub infrastructure first** (required by IaaS and PaaS layers):

   ```bash
   cd hub
   # Edit terraform.tfvars with your values (sample values are already provided)
   terraform init
   terraform apply
   ```

3. **Then deploy workload layers** (one or both):

   **IaaS Deployment:**

   ```bash
   cd ../iaas-app
   # Edit terraform.tfvars with your values (sample values are already provided)
   terraform init
   terraform apply
   ```

   **PaaS Deployment:**

   ```bash
   cd ../paas-app
   # Edit terraform.tfvars with your values (sample values are already provided)
   terraform init
   terraform apply
   ```

> **Deployment Order**: Hub must be deployed first. IaaS and PaaS layers reference the hub's Key Vault and Private DNS Zone.

For detailed instructions, see the [Deployment Guide](DEPLOYMENT.md).

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

## Prerequisites (Detailed)

- Azure subscription
- [Terraform](https://www.terraform.io/downloads.html) >= 1.10.0 (tested with 1.10.5)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed and authenticated
- Appropriate Azure permissions to create resources

## Authentication

Authenticate to Azure using the Azure CLI:

```bash
az login
az account set --subscription "<your-subscription-id>"
```

## ⚙️ Deployment Options

### Step 1: Hub Infrastructure (Deploy First)

Deploy core networking infrastructure with secure remote access and centralized secrets:

```bash
cd hub
# Edit terraform.tfvars with your values (sample values are already provided)
terraform init
terraform plan
terraform apply
```

**Resources Created:**

- Virtual Network with subnets (Bastion, Jumpbox, Private Endpoint)
- Azure Bastion for secure RDP/SSH access
- Windows Server 2022 Jumpbox VM
- NAT Gateway for outbound internet access
- Azure Key Vault with Private Endpoint (centralized secrets)
- Private DNS Zone (`privatelink.vaultcore.azure.net`)
- Network Security Groups

📖 [Full documentation](hub/README.md)

### Step 2a: IaaS Deployment (Requires Hub)

Deploy traditional VM-based infrastructure for web and database tiers:

```bash
cd iaas-app
# Edit terraform.tfvars with your values (sample values are already provided)
terraform init
terraform plan
terraform apply
```

**Resources Created:**

- Virtual Network with web and data subnets
- Windows Web Server VM
- SQL Server 2022 VM with optimized storage
- NAT Gateway for outbound internet access
- VNet Peering to hub network
- Private DNS Zone link to hub's Key Vault DNS zone
- Network Security Groups with tier-appropriate rules
- Optional public IP for web access

📖 [Full documentation](iaas-app/README.md)

### Step 2b: PaaS Deployment (Requires Hub)

Deploy modern cloud-native PaaS services:

```bash
cd paas-app
# Edit terraform.tfvars with your values (sample values are already provided)
terraform init
terraform plan
terraform apply
```

**Resources Created:**

- App Service Plan and App Service with Private Endpoint
- Azure SQL Server and Database with Private Endpoint
- Virtual Network with VNet integration
- NAT Gateway for outbound internet access
- VNet Peering to hub network
- Private DNS Zone link to hub's Key Vault DNS zone
- Application Insights

📖 [Full documentation](paas-app/README.md)

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

```bash
cd hub && terraform apply
cd ../iaas-app && terraform apply
```

### Scenario 2: Hub + PaaS (Cloud-Native)

```bash
cd hub && terraform apply
cd ../paas-app && terraform apply
```

### Scenario 3: Complete Environment (Hub + IaaS + PaaS)

Combine hub infrastructure with both IaaS and PaaS workloads:

```bash
cd hub && terraform apply
cd ../iaas-app && terraform apply
cd ../paas-app && terraform apply
```

> **Note**: Hub must always be deployed first. IaaS and PaaS layers can be deployed in any order after hub.

See [Architecture Guide](ARCHITECTURE.md) for detailed patterns.

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
