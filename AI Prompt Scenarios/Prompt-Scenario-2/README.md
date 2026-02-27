# Prompt Scenario 2 — IaaS Lift & Shift: Permit Management System

![.NET](https://img.shields.io/badge/.NET_8-512BD4?logo=dotnet&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL_Server_2022-CC2927?logo=microsoftsqlserver&logoColor=white)
![IIS](https://img.shields.io/badge/IIS-0078D4?logo=microsoftazure&logoColor=white)
![Bicep](https://img.shields.io/badge/Bicep-0078D4?logo=microsoftazure&logoColor=white)
![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=githubcopilot&logoColor=white)

> **Difficulty:** Intermediate &nbsp;|&nbsp; **Estimated time:** 3–4 hours

A SLED-focused lift-and-shift migration of an on-premises permit management system to Azure Virtual Machines. Built end-to-end using GitHub Copilot Agent mode.

**Why this scenario?** Many government agencies run critical workloads on aging on-premises Windows servers with SQL Server databases — and lack the budget or timeline for a full re-architecture. This scenario shows how to lift and shift that workload to Azure IaaS with minimal code changes, while adding network isolation, Key Vault-managed credentials, and audit logging that on-premises deployments often lack.

> **Note on .NET version:** This scenario targets **.NET 8** (vs. .NET 10 in Scenario 1) because IIS on Windows Server 2022 has the most stable, production-tested support for .NET 8 in a lift-and-shift context.

---

## ⚡ Quick Start

### 1. Verify Your Environment

Your Windows 365 desktop is pre-configured with the tools you need. Open VS Code, switch Copilot Chat to **Agent mode**, and paste:

```text
Check my environment and confirm everything I need for this scenario is installed and working:

1. Verify each tool is installed and show its version:
   - .NET 8 SDK: run `dotnet --version` (must be 8.x)
   - Azure CLI: run `az --version`
   - Bicep CLI: run `az bicep version`
   - PowerShell 7+: run `pwsh --version` (must be 7+)

2. Run `az account show` — confirm I am logged in and show me the active subscription name and ID.

3. If anything is missing or outdated, install or fix it now and show me the corrected output.
```

### 2. Open GitHub Copilot Chat

Open a new empty folder in VS Code and switch Copilot Chat to **Agent mode**.

### 3. Paste and Run the Prompt

Copy the full prompt below into Copilot Chat and press **Enter**. Copilot will generate the complete application — plan, files, and deployment commands.

<details>
<summary><strong>View full Copilot prompt</strong></summary>

```text
You are a senior full-stack developer and Azure infrastructure engineer helping a county building department perform a lift-and-shift migration of their on-premises permit management system to Azure IaaS (Virtual Machines).

GOAL
Build a complete web application designed to run on Azure IaaS infrastructure:
- Backend/Frontend: ASP.NET Core MVC on .NET 8 (deployed to IIS on Windows Server 2022)
- Database: SQL Server 2022 on Azure VM
- Infrastructure as Code: Bicep templates
- Deployment: PowerShell scripts to configure IIS and deploy the app to the VM
- Security: Network-isolated VMs, Azure Key Vault for credentials, no public SQL access
- Compliance-friendly: audit logging for status changes, environment tagging

PRIMARY USER STORY (SLED-themed sample domain)
Implement a "Permit Management" system for a fictional county building department:

Entity: PermitApplication
Fields:
- id (int, identity)
- permitNumber (string, auto-generated)
- applicantName (string)
- applicantEmail (string)
- permitType (Building|Electrical|Plumbing|Zoning)
- status (Submitted|UnderReview|Approved|Rejected|Expired)
- propertyAddress (string)
- description (string)
- submittedAt (datetime)
- reviewedAt (datetime, nullable)
- reviewedBy (string, nullable)
- notes (string, nullable)
- fee (decimal)
- feePaid (bool)

REPO STRUCTURE
/
  infra/
    main.bicep
    modules/
      network.bicep
      web-vm.bicep
      sql-vm.bicep
      keyvault.bicep
    main.bicepparam
  src/
    PermitManagement/   (ASP.NET Core MVC)
      Controllers/
      Models/
      Views/
      Data/
      wwwroot/
  scripts/
    setup-iis.ps1         (installs IIS + .NET hosting bundle)
    deploy-app.ps1        (publishes and copies app to web VM)
  README.md

APPLICATION REQUIREMENTS (ASP.NET Core MVC on .NET 8)
1) ASP.NET Core MVC with:
   - Razor Views for all pages
   - Bootstrap 5 for styling
   - Entity Framework Core with SQL Server provider
   - Connection string from environment variables / appsettings.json

2) Pages:
   - Permit list (filterable by status and permit type, paginated)
   - Permit detail view
   - Create permit form
   - Edit permit form
   - Delete with confirmation dialog
   - Simple dashboard: count of permits by status (use a summary bar or card layout)

3) Features:
   - Status badge (color-coded per status)
   - Auto-generate permitNumber on create (format: YYYY-TYPE-NNNN)
   - Audit log: write a log entry to a separate AuditLog table on every status change
   - Server-side + client-side form validation

4) Configuration:
   - Connection string via environment variable (injected by Bicep deployment)
   - No hardcoded credentials anywhere

5) Error handling and logging:
   - Friendly error pages (400, 404, 500)
   - Structured logging via ILogger

6) Unit tests:
   - xUnit tests for permit number generation and status transition logic

INFRASTRUCTURE (BICEP) — MUST INCLUDE
Deploy:
- Virtual Network with:
  - Web subnet (10.x.1.0/24)
  - Data subnet (10.x.2.0/24)
  - NSG on each subnet
- Windows Server 2022 VM (web tier):
  - Public IP for demo access (HTTP 80 / HTTPS 443 open inbound)
  - Custom Script Extension: run setup-iis.ps1 on first boot to install IIS + .NET 8 ASP.NET Core Hosting Bundle
  - System-managed identity
- SQL Server 2022 VM (data tier):
  - Private IP only — no public access
  - NSG: allow port 1433 from web subnet only
  - SQL IaaS Agent Extension
  - Two premium data disks (data + log)
- Azure Key Vault:
  - Store SQL admin username and password
  - Web VM identity granted Key Vault Secrets User role
- Tags: environment, owner, costCenter

DEPLOYMENT SCRIPTS
1) scripts/setup-iis.ps1:
   - Install IIS with required Windows features (Web-Server, Web-Asp-Net45, Web-Net-Ext45, etc.)
   - Install .NET 8 ASP.NET Core Hosting Bundle
   - Create IIS website bound to port 80 pointing to C:\inetpub\PermitManagement

2) scripts/deploy-app.ps1:
   - Run: dotnet publish src/PermitManagement -c Release -o ./publish
   - Copy published output to web VM via PowerShell remoting (Enter-PSSession / Invoke-Command)
   - Inject connection string as environment variable on the VM
   - Restart IIS app pool

DOCUMENTATION
README must include:
- Architecture diagram (ASCII showing hub VNet, web VM, SQL VM, Key Vault)
- Local dev instructions (use LocalDB or SQL Server Express)
- How to deploy with Bicep and deployment scripts
- How to connect to VMs via Azure Bastion
- Security notes (Key Vault, network isolation, no public SQL)
- SLED notes: audit logging, permit lifecycle, compliance tagging

NON-FUNCTIONAL / SLED GUARDRAILS
- Compliance tags on all Azure resources
- Audit log table captures: who changed status, from what, to what, when
- No secrets in source control
- Parameterize environment names (dev/staging/prod)
- Follow least-privilege for VM managed identities

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

## 🏗️ What You'll Build

- **Backend/Frontend**: ASP.NET Core MVC (.NET 8) with Razor Views
- **Database**: SQL Server 2022 on Azure VM
- **Infrastructure**: Bicep templates
- **Hosting**: IIS on Windows Server 2022 VM
- **Security**: Key Vault for credentials, network-isolated VMs
- **Observability**: Structured logging + audit log table

---

## ☁️ Deploy to Azure

```bash
# Deploy infrastructure
az deployment sub create \
  --location eastus \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam

# Deploy app to VM
pwsh scripts/deploy-app.ps1
```

---

## ✅ Evaluation

- [ ] App is running and accessible on the Azure web VM
- [ ] All CRUD operations work (create, list, edit, delete a permit)
- [ ] SQL Server VM is connected and storing data
- [ ] Infrastructure deployed via Bicep
- [ ] **Bonus:** Audit log captures status changes
