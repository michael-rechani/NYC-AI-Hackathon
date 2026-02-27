# PaaS Deployment (App Service and Azure SQL)

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)
![Microsoft Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?logo=microsoftazure&logoColor=white)
![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=githubcopilot&logoColor=white)

This module deploys Azure PaaS infrastructure for a modern cloud-native application including:
- App Service Plan (Windows or Linux)
- App Service Web App with Private Endpoint
- Azure SQL Database with Private Endpoint
- Virtual Network with VNet Integration
- NAT Gateway for outbound internet access
- VNet Peering to hub network
- Private DNS Zone link to hub's Key Vault DNS zone
- Application Insights for monitoring

> **Prerequisite**: The [hub](../hub/README.md) layer must be deployed first. This module references the hub's Key Vault (for storing credentials) and Private DNS Zone (for Key Vault private connectivity).

## 🤖 Use GitHub Copilot

Open this folder in VS Code, switch Copilot Chat to **Agent mode**, and paste the prompt below.

<details>
<summary><strong>View Copilot prompt</strong></summary>

```text
You are a senior Azure infrastructure engineer. The existing Terraform configuration
in this folder deploys a PaaS landing zone: Azure App Service with VNet integration,
Azure SQL Database with a private endpoint, Application Insights, and VNet peering
to the hub.

PREREQUISITE
The hub/ module must already be deployed. You will need the hub's output values:
- hub_resource_group_name
- hub_vnet_name
- hub_key_vault_name
Run `cd ../hub && terraform output` to retrieve them if needed.

TASK
Review the existing Terraform files and help me:

1. Explain the PaaS architecture — how App Service connects to SQL Database via
   private networking and why this is more secure than a public connection string.

2. Walk me through terraform.tfvars — identify every value I need to update,
   especially the hub cross-references and the runtime stack setting (e.g., .NET,
   Python, or Node.js).

3. Guide me step-by-step through terraform init, terraform plan, and
   terraform apply.

4. After deployment, show me how to retrieve the App Service URL and Application
   Insights connection string from terraform output.

5. Explain the Next Steps: how to deploy application code to App Service and how
   to configure the SQL Database schema.

6. Help me troubleshoot any errors during plan or apply.

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

Then use the Copilot prompt above — it will walk you through the hub cross-references in `terraform.tfvars`, run `terraform init`, `terraform plan`, and `terraform apply`, and show you how to retrieve the App Service URL and SQL credentials.

## Resources Created

- Resource Group
- Virtual Network with 2 subnets:
  - appservice-subnet (for VNet integration, delegated to Microsoft.Web/serverFarms)
  - privateendpoint-subnet (for private endpoints)
- App Service Plan (configurable SKU)
- App Service (with VNet integration and Private Endpoint)
- Azure SQL Server with Private Endpoint
- Azure SQL Database (configurable tier, serverless supported)
- NAT Gateway with public IP (for App Service outbound access)
- VNet Peering (bidirectional) to hub VNet
- Private DNS Zone link to hub's `privatelink.vaultcore.azure.net` zone
- Private DNS Zones for App Service and SQL private endpoints
- Application Insights for monitoring

## App Service Configuration

The App Service is configured with:
- HTTPS only
- HTTP/2 enabled
- Minimum TLS 1.2
- VNet integration (optional)
- Connection string to SQL Database (optional)
- Application Insights integration
- Configurable runtime stack (.NET, Node.js, Python, etc.)

## SQL Database Configuration

The SQL Database supports:
- Multiple service tiers (Basic, Standard, Premium, General Purpose, Business Critical)
- Zone redundancy
- Read scale-out
- Auto-pause for serverless (cost optimization)
- Firewall rules for Azure services
- Private endpoint for secure access

## Outputs

After deployment, review outputs and retrieve credentials from the Hub Key Vault:

```bash
# Get App Service URL
terraform output app_service_url

# Get Application Insights instrumentation key
terraform output -raw application_insights_instrumentation_key

# Retrieve SQL admin credentials from the Hub Key Vault
cd ../hub
KV_NAME=$(terraform output -raw key_vault_name)
cd ../paas-app
az keyvault secret show --vault-name $KV_NAME --name paas-sql-admin-username --query value -o tsv
az keyvault secret show --vault-name $KV_NAME --name paas-sql-admin-password --query value -o tsv
```

## Azure Verified Modules Used

- [Virtual Network](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest)
- [App Service Plan](https://registry.terraform.io/modules/Azure/avm-res-web-serverfarm/azurerm/latest)
- [SQL Server](https://registry.terraform.io/modules/Azure/avm-res-sql-server/azurerm/latest)

App Service uses native azurerm resources for maximum compatibility.

## Deployment Options

### Basic (Development)
- App Service Plan: B1 or S1
- SQL Database: Basic or S0
- No VNet integration
- No private endpoints

### Standard (Production)
- App Service Plan: P1v3 or higher
- SQL Database: S1 or higher
- VNet integration enabled
- Optional private endpoints

### Premium (Enterprise)
- App Service Plan: P2v3 or higher
- SQL Database: P1 or GP_Gen5_2
- VNet integration enabled
- Private endpoints enabled
- Zone redundancy enabled

## Next Steps

After deployment:
1. Deploy your application code to App Service
2. Configure database schema and data
3. Set up custom domains and SSL certificates
4. Configure authentication and authorization
5. Review Application Insights telemetry
