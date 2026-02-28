# Deployment Guide

> **Note**: The recommended path for this workshop is to use GitHub Copilot in Agent mode — open each module folder in VS Code, paste the Copilot prompt from that module's README, and let Copilot guide you through configuration and deployment. This guide is for participants who prefer to deploy manually without Copilot assistance.

This guide provides step-by-step instructions for deploying the Azure infrastructure using Terraform.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Deployment Scenarios](#deployment-scenarios)
4. [Post-Deployment](#post-deployment)
5. [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have:

- **Azure Subscription**: Active Azure subscription with appropriate permissions
- **Terraform**: Version 1.10.0 or higher (tested with 1.10.5) ([Download](https://www.terraform.io/downloads.html))
- **Azure CLI**: Latest version ([Download](https://learn.microsoft.com/cli/azure/install-azure-cli))
- **Permissions**: Contributor or Owner role on the Azure subscription
- **Shell**: Bash, WSL, or PowerShell 7+ (examples include both where needed)

## Initial Setup

### 1. Install Required Tools

Use the Copilot prompt in each module's README to install required tools, or download Terraform directly from [terraform.io](https://www.terraform.io/downloads.html) and Azure CLI from [learn.microsoft.com](https://learn.microsoft.com/cli/azure/install-azure-cli).

### 2. Authenticate to Azure

```bash
# Login to Azure
az login

# Set your subscription (if you have multiple)
az account list --output table
az account set --subscription "<your-subscription-id>"

# Verify the active subscription
az account show
```

### 3. Clone the Repository

```bash
git clone https://github.com/microsoft/NYC-AI-Hackathon.git
cd NYC-AI-Hackathon
```

## Deployment Scenarios

### Scenario 1: Hub Infrastructure

Deploy core networking with Bastion, Jumpbox, and centralized Key Vault. **This must be deployed first** as IaaS and PaaS layers depend on it.

#### Steps:

1. Navigate to the hub directory:
```bash
cd hub
```

2. Edit `terraform.tfvars` with your values (sample values are already provided):
```hcl
resource_group_name = "rg-hub-prod"
location            = "eastus"
vnet_name          = "vnet-hub-prod"
bastion_name       = "bastion-hub-prod"
jumpbox_name       = "jbox-hub-prod"    # Must be ≤ 15 characters
key_vault_name     = "kv-hubprod"

tags = {
  Environment = "Production"
  ManagedBy   = "Terraform"
  Owner       = "YourTeam"
}
```

> **Important**: Windows computer names (e.g., `jumpbox_name`) must be 15 characters or fewer.

3. Initialize Terraform:
```bash
terraform init
```

4. Review the plan:
```bash
terraform plan
```

5. Apply the configuration:
```bash
terraform apply
```

7. **Credentials are automatically stored in Key Vault**:
   - All VM credentials are randomly generated and stored in the hub Key Vault
   - Retrieve credentials from Key Vault when needed (see [Access Credentials](#access-credentials))
   - Never store credentials in files or version control

### Scenario 2: IaaS Deployment (Web + SQL VMs)

Deploy traditional VM-based infrastructure.

> **Prerequisite**: Deploy the hub first. This layer references the hub's Key Vault and Private DNS Zone.

#### Steps:

1. Navigate to the IaaS directory:
```bash
cd ../iaas-app
```

2. Edit `terraform.tfvars` with your values (sample values are already provided)
   - Ensure `hub_resource_group_name`, `hub_vnet_name`, and `hub_key_vault_name` match your hub deployment
   - Keep `web_vm_name` and `sql_vm_name` to 15 characters or fewer

3. Deploy:
```bash
terraform init
terraform plan
terraform apply
```

4. **Credentials are automatically stored in Hub Key Vault**:
   - VM credentials are randomly generated and stored securely
   - Retrieve from Key Vault when needed (see [Access Credentials](#access-credentials))

### Scenario 3: PaaS Deployment (App Service + Azure SQL)

Deploy modern cloud-native PaaS services.

> **Prerequisite**: Deploy the hub first. This layer references the hub's Key Vault and Private DNS Zone.

#### Steps:

1. Navigate to the PaaS directory:
```bash
cd ../paas-app
```

2. Update SQL Server name (must be globally unique) in `terraform.tfvars`:

Example:
```hcl
sql_server_name = "sql-myapp-${random_string}-prod"
# Or use your company name
sql_server_name = "sql-contoso-prod-001"
```
   - Ensure `hub_key_vault_name` and `hub_resource_group_name` match your hub deployment

3. Deploy:
```bash
terraform init
terraform plan
terraform apply
```

4. Get the App Service URL:
```bash
terraform output -raw app_service_url
```

### Scenario 4: Complete Environment

Deploy all components for a complete hub-and-spoke environment.

> **Deployment order matters**: Hub must be deployed first. IaaS and PaaS can be deployed in any order after hub.

1. **First**, deploy hub infrastructure:
```bash
cd hub
terraform apply
```

2. **Then**, deploy IaaS workloads:
```bash
cd ../iaas-app
terraform apply
```

3. **Then**, deploy PaaS workloads:
```bash
cd ../paas-app
terraform apply
```

## Post-Deployment

### Verify Resources

Check that resources were created successfully:

```bash
# List all resource groups
az group list --output table

# List resources in a specific group
az resource list --resource-group rg-hub-prod --output table
```

### Access Resources

#### Connect to Jumpbox via Bastion

1. Go to the Azure Portal
2. Navigate to your Resource Group
3. Click on the Bastion resource
4. Click "Connect" on the Jumpbox VM
5. Enter credentials retrieved from Key Vault (see [Access Credentials](#access-credentials))

#### Access App Service

**Bash/WSL:**
```bash
cd paas-app
APP_URL=$(terraform output -raw app_service_url)
echo $APP_URL

open $APP_URL  # macOS
xdg-open $APP_URL  # Linux
```

**PowerShell:**
```powershell
cd paas-app
$appUrl = terraform output -raw app_service_url
$appUrl
Start-Process $appUrl
```

#### Connect to SQL Database

**Bash/WSL:**
```bash
SQL_SERVER=$(terraform output -raw sql_server_fqdn)
SQL_DATABASE=$(terraform output -raw sql_database_name)

cd ../hub
KV_NAME=$(terraform output -raw key_vault_name)
cd ../paas-app
SQL_ADMIN=$(az keyvault secret show --vault-name $KV_NAME --name paas-sql-admin-username --query value -o tsv)
SQL_PASSWORD=$(az keyvault secret show --vault-name $KV_NAME --name paas-sql-admin-password --query value -o tsv)

sqlcmd -S $SQL_SERVER -U $SQL_ADMIN -P $SQL_PASSWORD -d $SQL_DATABASE
```

**PowerShell:**
```powershell
$sqlServer = terraform output -raw sql_server_fqdn
$sqlDatabase = terraform output -raw sql_database_name

cd ../hub
$kvName = terraform output -raw key_vault_name
cd ../paas-app
$sqlAdmin = az keyvault secret show --vault-name $kvName --name paas-sql-admin-username --query value -o tsv
$sqlPassword = az keyvault secret show --vault-name $kvName --name paas-sql-admin-password --query value -o tsv

sqlcmd -S $sqlServer -U $sqlAdmin -P $sqlPassword -d $sqlDatabase
```

### Access Credentials from Key Vault

**All credentials are automatically stored in the Hub Key Vault.**

Retrieve credentials when needed:

```bash
# Get the Key Vault name from hub outputs
cd hub
KV_NAME=$(terraform output -raw key_vault_name)

# List all secrets
az keyvault secret list --vault-name $KV_NAME --query "[].name" -o table

# Retrieve specific credentials
# Jumpbox credentials
az keyvault secret show --vault-name $KV_NAME --name hub-jumpbox-admin-username --query value -o tsv
az keyvault secret show --vault-name $KV_NAME --name hub-jumpbox-admin-password --query value -o tsv

# IaaS VM credentials
az keyvault secret show --vault-name $KV_NAME --name iaas-web-admin-username --query value -o tsv
az keyvault secret show --vault-name $KV_NAME --name iaas-web-admin-password --query value -o tsv
az keyvault secret show --vault-name $KV_NAME --name iaas-sql-admin-username --query value -o tsv
az keyvault secret show --vault-name $KV_NAME --name iaas-sql-admin-password --query value -o tsv

# PaaS SQL credentials
az keyvault secret show --vault-name $KV_NAME --name paas-sql-admin-username --query value -o tsv
az keyvault secret show --vault-name $KV_NAME --name paas-sql-admin-password --query value -o tsv
```

**Security Note:** Credentials are randomly generated during deployment and never stored in Terraform outputs or files.

## Security Best Practices

- Do not commit secrets to source control.
- Store credentials in Key Vault only (these modules do this by default).
- Avoid placing secrets in `terraform.tfvars` files.
- Restrict Key Vault access to least privilege.

## Terraform State Management

> **Important**: This repository includes sample `terraform.tfstate` files for workshop/demo purposes. Remove `terraform.tfstate*` and the `.terraform` directory before running your own deployments.

By default, Terraform stores state locally — this is fine for this PoC/hackathon context. Remote state backend configuration (Azure Storage) is out of scope for this event.

## Updating Infrastructure

### Modify Resources

1. Edit `terraform.tfvars` or `.tf` files
2. Review changes:
```bash
terraform plan
```
3. Apply changes:
```bash
terraform apply
```

### Add New Resources

1. Add resource definitions to `main.tf`
2. Add variables to `variables.tf`
3. Add outputs to `outputs.tf`
4. Plan and apply

## Destroying Resources

### Destroy Individual Modules

```bash
cd hub
terraform destroy
```

### Destroy in Order (if dependent)

Destroy in reverse order of creation:

1. PaaS workloads
2. IaaS workloads
3. Hub infrastructure

```bash
cd paas-app
terraform destroy

cd ../iaas-app
terraform destroy

cd ../hub
terraform destroy
```

## Troubleshooting

### Common Issues

#### 1. Terraform Version Mismatch

**Error**: "Unsupported Terraform Core version"

**Solution**:
```bash
terraform version
# Upgrade to >= 1.10.0
```

#### 2. Azure Authentication Failure

**Error**: "Error building account: could not acquire access token"

**Solution**:
```bash
az logout
az login
az account set --subscription "<subscription-id>"
```

#### 3. Resource Already Exists

**Error**: "A resource with the ID already exists"

**Solution**:
```bash
# Import existing resource
terraform import <resource_type>.<name> <azure_resource_id>

# Or, delete the existing resource in Azure Portal
```

#### 4. Name Not Globally Unique

**Error**: "Name is not available" (for SQL Server, Storage Account, etc.)

**Solution**: Choose a different name with more uniqueness:
```hcl
sql_server_name = "sql-mycompany-${random_id}-prod"
```

#### 5. Insufficient Permissions

**Error**: "Authorization failed"

**Solution**: Ensure you have Contributor or Owner role:
```bash
az role assignment list --assignee $(az account show --query user.name -o tsv)
```

#### 6. Subscription Quota Limits

**Error**: "Operation could not be completed as it results in exceeding approved quota"

**Solution**:
- Request quota increases in the Azure portal
- Reduce SKU sizes in `terraform.tfvars`
- Deploy to a different region with available capacity

#### 7. EncryptionAtHost Not Supported

**Error**: "The resource type 'virtualMachines' does not support Encryption at Host"

**Cause**: The `Microsoft.Compute/EncryptionAtHost` feature is not registered on your subscription.

**Solution**: Either register the feature or set `encryption_at_host_enabled = false` in the VM module:
```bash
# Register the feature (takes a few minutes)
az feature register --name EncryptionAtHost --namespace Microsoft.Compute
az feature show --name EncryptionAtHost --namespace Microsoft.Compute --query properties.state

# After registration completes, re-register the provider
az provider register --namespace Microsoft.Compute
```

#### 8. VM Computer Name Too Long

**Error**: "Computer name must be 1-15 characters long"

**Cause**: Windows VMs have a 15-character limit for `computer_name`. The AVM compute module uses the VM name as the computer name.

**Solution**: Keep `jumpbox_name`, `web_vm_name`, and `sql_vm_name` to 15 characters or fewer.

#### 9. Hub Not Deployed Before Spoke Layers

**Error**: Errors referencing missing Key Vault, DNS zone, or VNet resources from the hub resource group

**Cause**: The IaaS and PaaS layers use `data` sources to look up hub resources at plan time.

**Solution**: Always deploy the `hub` layer first before `iaas-app` or `paas-app`.

### Get Help

- **Terraform Issues**: [Terraform GitHub Issues](https://github.com/hashicorp/terraform/issues)
- **Azure Provider**: [AzureRM Provider Issues](https://github.com/hashicorp/terraform-provider-azurerm/issues)
- **Azure Verified Modules**: [AVM Documentation](https://azure.github.io/Azure-Verified-Modules/)

## Best Practices

1. **Never commit secrets** — keep credentials out of `.tfvars` and source control
2. **Tag resources** consistently for cost tracking and cleanup
3. **Plan before apply** — always review `terraform plan` output before applying
4. **Destroy when done** — tear down resources after the event to avoid unnecessary costs

## Next Steps

Once your infrastructure is deployed, head back to your chosen scenario to build and deploy your application:

- [Scenario 1 — SLED Case Management CRUD App](../AI%20Prompt%20Scenarios/Prompt-Scenario-1/README.md)
- [Scenario 2 — IaaS Lift & Shift: Permit Management](../AI%20Prompt%20Scenarios/Prompt-Scenario-2/README.md)
- [Scenario 3 — AI Constituent Services Chatbot](../AI%20Prompt%20Scenarios/Prompt-Scenario-3/README.md)
