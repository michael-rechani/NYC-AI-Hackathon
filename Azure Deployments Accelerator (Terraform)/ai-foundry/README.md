# Azure AI Foundry Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)
![Microsoft Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?logo=microsoftazure&logoColor=white)
![Azure OpenAI](https://img.shields.io/badge/Azure_OpenAI-0078D4?logo=microsoftazure&logoColor=white)
![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=githubcopilot&logoColor=white)

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

## 🤖 Use GitHub Copilot

Open this folder in VS Code, switch Copilot Chat to **Agent mode**, and paste the prompt below.

<details>
<summary><strong>View Copilot prompt</strong></summary>

```text
You are a senior Azure AI infrastructure engineer. The existing Terraform
configuration in this folder deploys an Azure AI Foundry hub with Azure OpenAI
(GPT-4o), connected to the hub VNet and optionally to the PaaS SQL Database
and IaaS SQL Server VM.

PREREQUISITES
The following modules must already be deployed:
- hub/       → provides Key Vault, Bastion, Private DNS
- paas-app/  → provides Azure SQL Database (for AI Foundry connection)
Run `cd ../hub && terraform output` and `cd ../paas-app && terraform output`
to retrieve the values you'll need.

TASK
Review the existing Terraform files and help me:

1. Explain the AI Foundry architecture — what AI Hub, AI Project, and AI
   Services are, how GPT-4o is accessed, and why private endpoints are used.

2. Walk me through terraform.tfvars — identify every value I need to update,
   including hub cross-references and whether to enable the IaaS SQL Private
   Link Service connection (enable_iaas_sql_pls).

3. Guide me step-by-step through terraform init, terraform plan, and
   terraform apply.

4. After deployment, show me how to open the AI Foundry hub in the Azure portal
   and start using Prompt Flow or AI Agents with the GPT-4o deployment.

5. If terraform apply fails due to GPT-4o quota limits, help me identify which
   Azure region has availability or suggest an alternative model deployment.

6. Help me troubleshoot any errors during plan or apply.

CONSTRAINTS
- Use the existing .tf files as-is. Do not rewrite them.
- Do not make changes to any file unless I explicitly ask.
```

</details>

---

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

Deploy these modules first (in order):

| Step | Module | Provides |
| --- | --- | --- |
| 1 | `hub/` | Key Vault, Bastion, Private DNS |
| 2 | `iaas-app/` | SQL VM + Private Link Service *(only if `enable_iaas_sql_pls = true`)* |
| 3 | `paas-app/` | App Service + Azure SQL Database |
| 4 | `ai-foundry/` | AI Hub, GPT-4o ← **YOU ARE HERE** |

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

Then use the Copilot prompt above — it will walk you through `terraform.tfvars` (hub cross-references, IaaS SQL PLS toggle, GPT-4o region and quota), run `terraform init`, `terraform plan`, and `terraform apply`, and guide you to the AI Foundry portal after deployment.

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
