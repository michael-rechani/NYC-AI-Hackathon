# PaaS Deployment (App Service and Azure SQL)

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

## Prerequisites

- Azure subscription
- Terraform >= 1.10.0
- Azure CLI authenticated
- **Hub infrastructure deployed** (provides Key Vault and DNS zone)

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
6. Set up CI/CD pipelines
