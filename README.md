# AI Hackathon for NYC Public Sector

<img src="./assets/banner.svg" alt="AI Hackathon for NYC Public Sector" width="100%"/>

![Microsoft Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?logo=microsoftazure&logoColor=white)
![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=githubcopilot&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-512BD4?logo=dotnet&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)
![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black)
![Bicep](https://img.shields.io/badge/Bicep-0078D4?logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)

A fast-paced, hands-on event where teams go from idea to working Azure application in a single day — built with GitHub Copilot, working side-by-side with Microsoft engineers.

Participants design, build, and deploy a real Azure application using secure, enterprise-ready services and leave with:

- A **working, deployed Azure application** you built yourself
- Hands-on experience with **GitHub Copilot Agent mode** for real-world development
- Reusable **infrastructure-as-code templates** for Azure deployments
- Practical knowledge of **SLED security patterns** (Managed Identity, RBAC, zero hardcoded secrets)

---

## ⚡ Before You Start

Your **Windows 365 desktop** comes pre-configured with VS Code, GitHub Copilot, Azure CLI, and an active Azure account — no setup required before the event.

To do a quick sanity check, open VS Code, switch Copilot Chat to **Agent mode**, and paste:

```text
Check my Windows 365 environment and confirm I'm ready to start:

1. Run `az account show` — confirm I am logged in to Azure and show me the active subscription name and ID.

2. Confirm the GitHub Copilot extension is installed and signed in to VS Code.

3. If anything is missing or not signed in, fix it now and show me the corrected output.
```

> Each scenario README includes its own environment-check prompt with the specific tools required — run that when you open your chosen scenario.

---

## 🚀 How It Works

1. **Pick a scenario** — Choose one of the challenge scenarios below based on your team's interests and skill set
2. **Use GitHub Copilot** — Follow the prompts in your scenario to generate and build your application in Agent mode
3. **Deploy to Azure** — Get your solution running on Microsoft Azure using the provided infrastructure templates
4. **Present your work** — Demo your application to the group at the end of the event

---

## 🤖 AI Prompt Scenarios

| # | Scenario | Description | Difficulty | Tech Stack | Est. Time |
| --- | --- | --- | --- | --- | --- |
| 1 | [SLED Case Management CRUD App](./AI%20Prompt%20Scenarios/Prompt-Scenario-1/README.md) | Secure case management system for a county agency | Intermediate | .NET 10 · React · Cosmos DB · Bicep | ~3–4 hrs |
| 2 | [IaaS Lift & Shift: Permit Management](./AI%20Prompt%20Scenarios/Prompt-Scenario-2/README.md) | Lift-and-shift permit management system to Azure VMs | Intermediate | .NET 8 · SQL Server VM · IIS · Bicep | ~3–4 hrs |
| 3 | [AI Constituent Services Chatbot](./AI%20Prompt%20Scenarios/Prompt-Scenario-3/README.md) | RAG-powered chatbot for government services using Azure OpenAI + Azure AI Search | Advanced | Python · FastAPI · React · Azure OpenAI · AI Search · Bicep | ~4–5 hrs |

> Not sure which to pick? Scenarios 1 and 2 are great starting points for teams focused on web app development. Scenario 3 is ideal for teams interested in AI and RAG patterns.

---

## 🏗️ Azure Deployments Accelerator (Terraform)

The [Azure Deployments Accelerator](./Azure%20Deployments%20Accelerator%20(Terraform)/README.md) provides ready-to-use Terraform modules for deploying a shared enterprise landing zone on Azure. It follows a hub-and-spoke network topology — deploy the Hub first to establish shared networking, Key Vault, and Bastion access, then add IaaS, PaaS, and AI Foundry spokes in any order.

```text
┌─────────────────────────────────────────────────────────────────────────┐
│  Step 1 — Hub  (required, deploy first)                                 │
│  Virtual Network · Azure Bastion · Jumpbox VM · Key Vault               │
│  NAT Gateway · Private DNS Zones · Network Security Groups              │
└─────────────────────────────────────────────────────────────────────────┘
                                    |  VNet Peering (hub-and-spoke)
                                    |
              ┌─────────────────────┼─────────────────────┐
              |                     |                     |
  ┌───────────┴──────────┐  ┌───────┴───────────────┐  ┌─┴───────────────────────┐
  │  Step 2a — IaaS      │  │  Step 2b — PaaS       │  │  Step 3 — AI Foundry    │
  │  Web Server VM       │  │  Azure App Service    │  │  AI Foundry Hub         │
  │  SQL Server 2022 VM  │  │  Azure SQL Database   │  │  Azure OpenAI (GPT-4o)  │
  │  (optional)          │  │  (optional)           │  │  (optional)             │
  └──────────────────────┘  └───────────────────────┘  └─────────────────────────┘
```

Each module's README includes a GitHub Copilot prompt that guides you through `terraform.tfvars`, `terraform init`, `terraform plan`, and `terraform apply`. For the full deployment guide, see [DEPLOYMENT.md](./Azure%20Deployments%20Accelerator%20(Terraform)/DEPLOYMENT.md).

> The three challenge scenarios include their own self-contained **Bicep** templates generated by Copilot — they deploy independently and do not require the Accelerator. The Accelerator is intended as a shared enterprise baseline for teams that want a production-ready Azure landing zone.
