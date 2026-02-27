# Prompt Scenario 1 — SLED Case Management CRUD App

Secure, production-ready case management system for a fictional county agency. Built end-to-end using GitHub Copilot Agent mode on Microsoft Azure.

---

## Quick Start

### 1. Check Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Node.js 20+](https://nodejs.org/) and npm
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) — run `az login` before starting
- [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) — run `az bicep install`
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Active Azure subscription with Contributor access

### 2. Open GitHub Copilot Chat

Open a new empty folder in VS Code and switch Copilot Chat to **Agent mode**.

### 3. Paste and Run the Prompt

Copy the full prompt below into Copilot Chat and press **Enter**. Copilot will generate the complete application — plan, files, and deployment commands.

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
  .github/workflows/
    ci.yml
    deploy.yml
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

CI/CD (GitHub Actions)
1) ci.yml — build + test API, build web
2) deploy.yml — deploy infra via Bicep, deploy API container image, deploy web to Static Web Apps
   - Deploy frontend by building with `npm run build` and deploying the dist/ folder
     directly using `az staticwebapp` CLI commands; do NOT use the SWA CLI
     (`swa deploy`) — it has known Node runtime compatibility issues

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
4) Commands to run locally and deploy

Do not leave TODO placeholders — implement end-to-end. Choose secure defaults.
```

> If Copilot stops before finishing, type `continue` and press **Enter**.

---

## What You'll Build

- **Backend**: ASP.NET Core Web API (.NET 10)
- **Frontend**: React + TypeScript (Vite)
- **Database**: Azure Cosmos DB for NoSQL
- **Infrastructure**: Bicep templates
- **Hosting**: Azure Container Apps (API) + Azure Static Web Apps (frontend)
- **Security**: Managed Identity + RBAC — no hardcoded keys
- **Observability**: Application Insights + Log Analytics

---

## Run Locally

```bash
# Frontend
cd src/web && npm install && npm run dev

# API (open a second terminal)
cd src/api && dotnet restore && dotnet run
```

> Paste any errors directly into Copilot Chat — it will help you resolve them.

---

## Deploy to Azure

```bash
az deployment sub create \
  --location eastus2 \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam
```

For the container and frontend deployment, follow the generated `deploy.yml` or ask Copilot:
> *"Walk me through deploying the API container and frontend to Azure with exact commands."*

---

## Evaluation

- [ ] App is deployed and accessible on Azure
- [ ] All CRUD operations work (create, list, edit, delete a case)
- [ ] Cosmos DB connected using Managed Identity (no hardcoded keys)
- [ ] Infrastructure deployed via Bicep
- [ ] **Bonus:** CI/CD pipeline runs in GitHub Actions
- [ ] **Bonus:** Application Insights shows live telemetry
