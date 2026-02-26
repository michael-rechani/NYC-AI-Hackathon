# Prompt Scenario 2 — IaaS Lift & Shift

> Use GitHub Copilot prompts to build and deploy a web application onto Azure Virtual Machines.

---

## The Scenario

You are a developer helping a company migrate a legacy on-premises application to Azure. Rather than re-architecting the app, the goal is a **lift and shift** — get the existing application running on Azure infrastructure with minimal changes. The VMs are already provisioned and waiting.

The application will run on a **Windows Server VM** (web tier) and connect to a **SQL Server VM** (data tier), just like it would on-premises.

---

## Your Mission

Use the GitHub Copilot prompts below to build and deploy your solution.

> **Prompts will be provided at the start of the event. The structure below shows what you'll be building toward.**

### What you'll build

- A web application deployed to a **Windows Server VM** running IIS
- A backend connected to a **SQL Server VM**
- Basic CRUD functionality simulating a real business application (e.g. employee directory, order management, inventory tracker)

### Suggested tech stack

- **Frontend/Backend**: ASP.NET or Node.js
- **Database**: SQL Server on Azure VM
- **Hosting**: IIS on Windows Server VM

---

## Evaluation

Your submission will be assessed on:

- Is the app running and accessible on the Azure VM?
- Does it successfully connect to and query SQL Server?
- Is the core functionality working end-to-end?
- Bonus: proper error handling, deployment script, documentation
