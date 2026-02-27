# Prompt Scenario 1 — SLED Case Management CRUD App

![.NET](https://img.shields.io/badge/.NET_10-512BD4?logo=dotnet&logoColor=white)
![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black)
![Cosmos DB](https://img.shields.io/badge/Cosmos_DB-0078D4?logo=microsoftazure&logoColor=white)
![Bicep](https://img.shields.io/badge/Bicep-0078D4?logo=microsoftazure&logoColor=white)
![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=githubcopilot&logoColor=white)

> **Difficulty:** Intermediate &nbsp;|&nbsp; **Estimated time:** 3–4 hours

Secure, production-ready case management system for a fictional county agency. Built end-to-end using GitHub Copilot Agent mode on Microsoft Azure.

**Why this scenario?** County agencies manage thousands of cases across services like social welfare, permitting, and public health — often in legacy systems with no audit trail. This scenario demonstrates how to build a modern, cloud-native CRUD app with security controls (Managed Identity, RBAC) and compliance features (audit logging, PII flags) that SLED agencies actually require before going to production.

## 🏗️ What You'll Build

- **Backend**: ASP.NET Core Web API (.NET 10)
- **Frontend**: React + TypeScript (Vite)
- **Database**: Azure Cosmos DB for NoSQL
- **Infrastructure**: Bicep templates
- **Hosting**: Azure Container Apps (API) + Azure Static Web Apps (frontend)
- **Security**: Managed Identity + RBAC — no hardcoded keys
- **Observability**: Application Insights + Log Analytics

---

## ⚡ Quick Start

### 1. Verify Your Environment

Your Windows 365 desktop is pre-configured with the tools you need. Open VS Code, switch Copilot Chat to **Agent mode**, and paste:

```text
Check my environment and confirm everything I need for this scenario is installed and working:

1. Verify each tool is installed and show its version:
   - .NET 10 SDK: run `dotnet --version` (must be 10.x)
   - Node.js: run `node --version` (must be 20+) and `npm --version`
   - Azure CLI: run `az --version`
   - Bicep CLI: run `az bicep version`
   - Docker Desktop: run `docker --version` and confirm Docker is running

2. Run `az account show` — confirm I am logged in and show me the active subscription name and ID.

3. If anything is missing, outdated, or not running, install or fix it now and show me the corrected output.
```

### 2. Open GitHub Copilot Chat

Open a new empty folder in VS Code and switch Copilot Chat to **Agent mode**.

### 3. Paste and Run the Prompt

Copy the full prompt below into Copilot Chat and press **Enter**. Copilot will generate the complete application — plan, files, and deployment commands.

<details>
<summary><strong>View full Copilot prompt</strong></summary>

```text
You are a senior full-stack engineer and Azure infrastructure engineer building a secure, production-ready reference CRUD application for State & Local Government (SLED).

GOAL
Build a complete CRUD web application using:
- Backend: ASP.NET Core Web API on .NET 10 (latest LTS)
- Frontend: React + TypeScript (Vite)
- Database: Azure Cosmos DB for NoSQL (SQL API)
- Infrastructure as Code: Bicep templates to deploy all Azure resources
- Observability: Application Insights + Log Analytics
- Security: Managed Identity + RBAC-first Cosmos access (no keys), least privilege, secure config
- Compliance-friendly: tagging, audit logging support, clear separation of environments

PRIMARY USER STORY (SLED-themed sample domain)
Implement a "Case Management" system for a fictional county agency:

Entity: CaseRecord
Fields:
- id (string, GUID)
- agencyId (string)  // partition key
- caseNumber (string, unique per agency)
- title (string)
- description (string)
- status (Open|InReview|Closed)
- priority (Low|Medium|High)
- createdAt (datetime)
- updatedAt (datetime)
- createdBy (string)
- assignedTo (string)
- piiFlag (bool) // sample compliance indicator

REPO STRUCTURE (monorepo)
/
  infra/
    main.bicep
    modules/
      cosmos.bicep
      identity.bicep
      monitoring.bicep
      app-api.bicep
      app-web.bicep
    main.bicepparam
  src/
    api/   (ASP.NET Core Web API)
    web/   (React TS)
  README.md

BACKEND REQUIREMENTS (.NET 10)
1) Use ASP.NET Core Web API (.NET 10) with:
   - Controllers or Minimal APIs (choose one and be consistent)
   - OpenAPI enabled using Microsoft.AspNetCore.OpenApi (built-in .NET 10 support)
     DO NOT use Swashbuckle — it is not compatible with .NET 10
   - Health endpoint (/health)
   - Validation (FluentValidation or data annotations)
   - Structured logging

2) Cosmos DB access:
   - Use Azure Cosmos DB .NET SDK
   - Use Managed Identity in Azure (DefaultAzureCredential)
   - Local dev uses a connection string via user-secrets or dotenv
   - Model + repository/service layer (clean architecture-lite)
   - Configure CosmosClient with System.Text.Json camelCase serialization
   - Annotate the id field with [JsonPropertyName("id")] to match Cosmos DB's
     required lowercase document id — do not rely on default property naming

3) CRUD endpoints:
   - GET /api/cases?agencyId=...
   - GET /api/cases/{id}?agencyId=...
   - POST /api/cases
   - PUT /api/cases/{id}
   - DELETE /api/cases/{id}?agencyId=...

4) Partition strategy:
   - Use /agencyId as partition key
   - Enforce providing agencyId on read/delete

5) Error handling:
   - Return consistent ProblemDetails

6) Add unit tests for service layer (xUnit)

FRONTEND REQUIREMENTS (React + TS)
1) Vite + React + TypeScript
2) Pages:
   - Case list (filter by agencyId)
   - Create case
   - Edit case
   - View details
3) API client:
   - Centralized fetch wrapper
   - Handles errors and shows toast/inline errors
4) Basic UI:
   - Use Fluent UI React v9 OR minimal CSS
5) Local config:
   - .env for API base URL

AZURE DEPLOYMENT TARGET
Option A (preferred):
- Frontend: Azure Static Web Apps
- API: Azure Container Apps (containerized)

INFRASTRUCTURE (BICEP) — MUST INCLUDE
Create Bicep that deploys:
- Azure Cosmos DB for NoSQL account + database + container
  - RBAC-first; include parameter to disable local auth (keys) in production
  - Output the Cosmos endpoint
- Managed Identity for the API
- Role assignments so API identity can read/write in the Cosmos container
- Log Analytics workspace + Application Insights
- Container Apps environment + Container App for API
- Static Web App for React frontend
- App configuration:
  - Inject Cosmos endpoint into API (NOT keys)
  - Inject APPINSIGHTS_CONNECTIONSTRING
  - Inject AZURE_CLIENT_ID (the user-assigned managed identity's client ID) so
    DefaultAzureCredential selects the correct identity rather than falling back
    to system-assigned or failing
- Tags: environment, dataClassification, owner, costCenter (parameters)

DOCUMENTATION
README must include:
- Architecture diagram (ASCII)
- Local dev instructions
- How to deploy with Bicep
- Required Azure permissions
- Security notes (Managed Identity, RBAC, disabling keys)
- SLED notes: compliance tags, audit logging, monitoring/alerts

NON-FUNCTIONAL / SLED GUARDRAILS
- Compliance tags and audit logging guidance
- Monitoring: API latency, error rate, Cosmos request charge tracking
- Parameterized naming conventions
- No secrets in source control — use environment variables
- Parameterize for Commercial vs Gov cloud

OUTPUT FORMAT
Produce:
1) A brief plan
2) The full folder/file list
3) The content for each file (with correct paths as headings)
4) Commands to deploy to Azure

Do not leave TODO placeholders — implement end-to-end. Choose secure defaults.
```

</details>

> If Copilot stops before finishing, type `continue` and press **Enter**.

---

## ✅ Evaluation

- [ ] App is deployed and accessible on Azure
- [ ] All CRUD operations work (create, list, edit, delete a case)
- [ ] Cosmos DB connected using Managed Identity (no hardcoded keys)
- [ ] Infrastructure deployed via Bicep
- [ ] **Bonus:** Application Insights shows live telemetry
