# Azure AI Foundry Infrastructure

This module deploys Azure AI Foundry and connects it to the SQL workloads running in the `paas-app` and `iaas-app` environments.

## Architecture

```text
┌─────────────────────────────────────────────────────────────────────┐
│ Resource Group: rg-ai-workshop                                       │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Virtual Network: vnet-ai-workshop (10.3.0.0/16)                │ │
│  │ ←── VNet Peering ──→ vnet-hub-workshop (10.0.0.0/16)          │ │
│  │                                                                 │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ AI Subnet (10.3.1.0/24)                                  │ │ │
│  │  │ → NAT Gateway (outbound internet)                        │ │ │
│  │  │ - AI Foundry compute instances                           │ │ │
│  │  │ - NSG: Allow AzureML, Batch inbound; HTTPS outbound      │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ Private Endpoint Subnet (10.3.2.0/24)                    │ │ │
│  │  │ - AI Foundry Hub PE (amlworkspace)                       │ │ │
│  │  │ - AI Services PE (account)                               │ │ │
│  │  │ - Storage PE (blob + file)                               │ │ │
│  │  │ - Azure SQL Database PE (sqlServer) ← paas-app           │ │ │
│  │  │ - IaaS SQL VM PE (via PLS) ← iaas-app (optional)        │ │ │
│  │  │ - ACR PE (registry, optional)                            │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ AI Foundry Hub (aihub-workshop)                                │ │
│  │ - Managed identity (system-assigned)                           │ │
│  │ - Managed network: AllowOnlyApprovedOutbound                   │ │
│  │ - Storage: staifoundryworkshop                                 │ │
│  │ - Key Vault: kv-hubworkshop (shared with hub)                 │ │
│  │                                                                 │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ AI Project (aiproj-sql-workshop)                         │ │ │
│  │  │ - Prompt Flow for NL-to-SQL                              │ │ │
│  │  │ - Agent tools with SQL function calling                  │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ AI Services (ais-workshop)                                     │ │
│  │ - Kind: AIServices (multi-service)                             │ │
│  │ - GPT-4o deployment                                            │ │
│  │ - Text Embedding deployment (optional)                        │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  Monitoring: Log Analytics + Application Insights                    │
│  DNS Zones: privatelink.api.azureml.ms,                              │
│             privatelink.notebooks.azure.net,                         │
│             privatelink.cognitiveservices.azure.com,                  │
│             privatelink.openai.azure.com,                            │
│             privatelink.blob.core.windows.net,                       │
│             privatelink.file.core.windows.net,                       │
│             privatelink.database.windows.net                         │
└─────────────────────────────────────────────────────────────────────┘
```

## SQL Connectivity

### PaaS Azure SQL Database (First-Class Support)

AI Foundry connects directly to Azure SQL Database via a private endpoint in the AI VNet:

```text
AI Foundry Project (prompt flow / agent)
    → Managed Identity (AAD auth)
    → Private Endpoint → privatelink.database.windows.net
    → Azure SQL Database (sql-paas-workshop)
```

**Capabilities enabled:**

- Natural language to SQL via GPT-4o
- RAG over structured SQL data
- Vector search using Azure SQL's native `VECTOR` data type
- AI Agents with SQL function calling tools

### IaaS SQL Server VM (Via Private Link Service)

Since AI Foundry has no native connector for SQL Server on VMs, connectivity flows through a Private Link Service (PLS) deployed in the `iaas-app` module:

```text
AI Foundry Project
    → Private Endpoint → Private Link Service (iaas-app)
    → Internal Load Balancer (data-subnet)
    → SQL Server VM (sql-iaas-wkshp:1433)
```

This requires deploying the PLS infrastructure in `iaas-app` first (see below).

## Prerequisites

1. **Hub infrastructure** deployed (`hub/` module)
2. **PaaS app** deployed (`paas-app/` module) — for Azure SQL Database connection
3. **IaaS app** deployed with PLS (`iaas-app/` module) — only if `enable_iaas_sql_pls = true`

## Deployment

```bash
cd ai-foundry

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy
terraform apply
```

### Deployment Order

```text
1. hub/           → Key Vault, Bastion, Private DNS
2. iaas-app/      → SQL VM + Private Link Service (optional)
3. paas-app/      → App Service + Azure SQL Database
4. ai-foundry/    → AI Hub, AI Services, SQL connections ← YOU ARE HERE
```

## Enabling IaaS SQL VM Access

After deploying the Private Link Service in `iaas-app`:

1. Get the PLS resource ID from `iaas-app` outputs:

   ```bash
   cd ../iaas-app && terraform output sql_private_link_service_id
   ```

2. Update `terraform.tfvars`:

   ```hcl
   enable_iaas_sql_pls              = true
   iaas_sql_private_link_service_id = "<output from step 1>"
   ```

3. Re-apply:

   ```bash
   cd ../ai-foundry && terraform apply
   ```

## Key Configuration

| Variable                        | Description                       | Default    |
| ------------------------------- | --------------------------------- | ---------- |
| `ai_hub_public_network_access`  | Public access to AI Hub           | `Disabled` |
| `ai_hub_sku`                    | Hub SKU tier                      | `Basic`    |
| `enable_paas_sql_connection`    | Private endpoint to Azure SQL DB  | `true`     |
| `enable_iaas_sql_pls`           | Private endpoint to SQL VM via PLS| `false`    |
| `enable_container_registry`     | Deploy ACR for custom models      | `false`    |
| `openai_deployments`            | Map of GPT model deployments      | GPT-4o     |

## Network Details

| Subnet                 | CIDR        | Purpose               |
| ---------------------- | ----------- | --------------------- |
| ai-subnet              | 10.3.1.0/24 | AI compute instances  |
| privateendpoint-subnet | 10.3.2.0/24 | All private endpoints |

VNet peering to hub (10.0.0.0/16) enables:

- Key Vault access via existing private endpoint
- Transitive connectivity to iaas-app (10.1.0.0/16) and paas-app (10.2.0.0/16) via hub
