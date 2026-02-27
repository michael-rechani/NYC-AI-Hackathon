# Prompt Scenario 3 — AI-Powered Constituent Services Chatbot

![Python](https://img.shields.io/badge/Python_3.12-3776AB?logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?logo=fastapi&logoColor=white)
![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black)
![Azure OpenAI](https://img.shields.io/badge/Azure_OpenAI-0078D4?logo=microsoftazure&logoColor=white)
![Bicep](https://img.shields.io/badge/Bicep-0078D4?logo=microsoftazure&logoColor=white)
![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=githubcopilot&logoColor=white)

> **Difficulty:** Advanced &nbsp;|&nbsp; **Estimated time:** 4–5 hours

A SLED-focused AI chatbot that helps citizens get accurate, citation-backed answers about government services — powered by Azure OpenAI and Retrieval-Augmented Generation (RAG). Built end-to-end using GitHub Copilot Agent mode.

**Why this scenario?** Government call centers and service portals are overwhelmed with routine questions — permit requirements, eligibility rules, appeal deadlines. This scenario builds a chatbot that answers those questions instantly with citations from authoritative sources, reducing call volume while improving accessibility. It demonstrates a complete RAG pipeline: from document ingestion and vector indexing to grounded, auditable AI responses that meet responsible AI requirements for public-sector deployment.

## 🏗️ What You'll Build

- **Backend**: Python + FastAPI
- **Frontend**: React + TypeScript (Vite)
- **AI**: Azure OpenAI GPT-4o via Azure AI Foundry
- **RAG**: Azure AI Search — grounds answers in real government FAQ content
- **Database**: Azure Cosmos DB for NoSQL (conversation history)
- **Hosting**: Azure App Service (API) + Azure Static Web Apps (frontend)
- **Security**: Managed Identity + RBAC — no hardcoded API keys

---

## ⚡ Quick Start

### 1. Verify Your Environment

Your Windows 365 desktop is pre-configured with the tools you need. Open VS Code, switch Copilot Chat to **Agent mode**, and paste:

```text
Check my environment and confirm everything I need for this scenario is installed and working:

1. Verify each tool is installed and show its version:
   - Python 3.12+: run `python --version` (must be 3.12+)
   - Node.js: run `node --version` (must be 20+) and `npm --version`
   - Azure CLI: run `az --version`
   - Bicep CLI: run `az bicep version`

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
You are a senior full-stack developer and Azure AI engineer building a secure, production-ready AI-powered constituent services application for a State & Local Government (SLED) agency.

GOAL
Build a complete web application with an integrated AI chatbot using:
- Backend: Python + FastAPI
- Frontend: React + TypeScript (Vite)
- AI: Azure OpenAI (GPT-4o) via Azure AI Foundry
- Vector Search: Azure AI Search for RAG (Retrieval-Augmented Generation)
- Database: Azure Cosmos DB for NoSQL (conversation history)
- Infrastructure as Code: Bicep templates
- Hosting: Azure App Service (Python) + Azure Static Web Apps (React frontend)
- Security: Managed Identity, no hardcoded API keys
- Compliance-friendly: responsible AI framing, audit logging, citation requirements

PRIMARY USER STORY (SLED-themed sample domain)
Build a "Constituent Services Assistant" for a fictional NYC government agency. Citizens ask natural-language questions about government services and receive accurate, citation-backed answers.

Sample questions the chatbot must handle:
- "How do I apply for a building permit?"
- "What documents do I need to renew my business license?"
- "What are the income limits for the housing assistance program?"
- "How do I appeal a parking ticket?"
- "Where do I go to get a marriage license?"

KNOWLEDGE BASE (RAG)
Create realistic sample government FAQ content as markdown files in knowledge-base/:
- building_permits_faq.md       (types, requirements, fees, timelines)
- business_licensing_faq.md     (new business, renewals, inspections)
- housing_assistance_faq.md     (eligibility, application process, income limits)
- parking_violations_faq.md     (appeals process, payment, hearings)
- general_services_faq.md       (hours, locations, contact info, accessibility)

Each file should contain at least 10 realistic Q&A pairs with enough detail to make the chatbot genuinely useful.

REPO STRUCTURE
/
  infra/
    main.bicep
    modules/
      ai-services.bicep
      ai-search.bicep
      cosmos.bicep
      app-service.bicep
      static-web-app.bicep
      identity.bicep
      monitoring.bicep
    main.bicepparam
  src/
    api/   (Python FastAPI)
    web/   (React TS)
  knowledge-base/   (FAQ markdown files)
  scripts/
    index-documents.py   (indexes knowledge base into Azure AI Search)
  README.md

BACKEND REQUIREMENTS (Python + FastAPI)
1) FastAPI application with:
   - POST /api/chat — accepts { message, session_id } returns { response, citations, session_id }
   - GET /api/chat/{session_id}/history — returns conversation history
   - DELETE /api/chat/{session_id} — clears a session
   - GET /health — health check
   - CORS configured for Static Web App origin

2) Azure OpenAI integration:
   - Use openai Python SDK with Azure endpoint
   - Use DefaultAzureCredential (Managed Identity in Azure, falls back to env var AZURE_OPENAI_API_KEY for local dev)
   - Model: gpt-4o
   - System prompt: professional, helpful government assistant persona; includes disclaimer that responses are for informational purposes only

3) RAG pipeline (run on every user message):
   - Call Azure AI Search to retrieve top 3 relevant FAQ chunks
   - Inject retrieved chunks as context into the system prompt
   - Include source filename and excerpt in response citations
   - If no relevant results found, respond with a helpful fallback message

4) Conversation history:
   - Store sessions in Azure Cosmos DB (partition key: /sessionId)
   - Maintain last 10 message pairs per session
   - Session ID generated client-side (UUID) and sent in every request

5) Response schema:
   {
     "response": "...",
     "citations": [{"source": "building_permits_faq.md", "excerpt": "..."}],
     "session_id": "uuid"
   }

6) Configuration (via environment variables):
   - AZURE_OPENAI_ENDPOINT
   - AZURE_OPENAI_DEPLOYMENT_NAME
   - AZURE_SEARCH_ENDPOINT
   - AZURE_SEARCH_INDEX_NAME
   - COSMOS_ENDPOINT
   - No secrets hardcoded or committed to source control

FRONTEND REQUIREMENTS (React + TS)
1) Vite + React + TypeScript
2) Chat interface:
   - Message thread (user messages right-aligned, assistant left-aligned)
   - Typing indicator (animated dots) while awaiting response
   - Citation cards shown below each assistant message (collapsible)
   - "New conversation" button that clears the thread and generates a new session ID
   - Session ID stored in localStorage so conversation persists on page refresh
   - Responsive layout (mobile-friendly)
3) Use Fluent UI React v9 OR minimal CSS
4) .env for API base URL (VITE_API_BASE_URL)

DOCUMENT INDEXING SCRIPT (scripts/index-documents.py)
- Reads all .md files from knowledge-base/
- Splits each file into chunks of ~400 tokens with 50-token overlap
- Uploads chunks to Azure AI Search index with fields:
  id, content, source, chunk_index
- Uses DefaultAzureCredential
- Prints progress to stdout

INFRASTRUCTURE (BICEP) — MUST INCLUDE
- Azure OpenAI account:
  - GPT-4o model deployment (capacity: 10 TPM)
  - Disable local auth; use RBAC only
- Azure AI Search (Basic tier):
  - Index schema: id (key), content (searchable), source (filterable), chunk_index
  - Semantic search configuration enabled
- Azure Cosmos DB for NoSQL:
  - Database + container for conversation history (partition key: /sessionId)
  - RBAC-first; no connection string keys in production
  - TTL: 7 days on conversation items
- Azure App Service (Linux, Python 3.12):
  - System-managed identity
  - App settings injected (OpenAI endpoint, Search endpoint, Cosmos endpoint)
  - Startup command: uvicorn src.main:app --host 0.0.0.0 --port 8000
- Azure Static Web App for React frontend
- Role assignments (all using Managed Identity — no keys):
  - App Service identity → Cognitive Services OpenAI User (OpenAI account)
  - App Service identity → Search Index Data Reader (AI Search)
  - App Service identity → Cosmos DB Built-in Data Contributor (Cosmos DB)
- Log Analytics workspace + Application Insights
- Tags: environment, dataClassification, owner, costCenter

DOCUMENTATION
README must include:
- Architecture diagram (ASCII)
- Local dev instructions (how to run without Azure using mock responses)
- Deployment steps
- Required Azure permissions
- Security notes (Managed Identity, no API keys, content filtering)
- SLED notes: responsible AI disclaimer, PII handling (do not log user queries with PII), citation requirements, accessibility (WCAG 2.1 AA target)

NON-FUNCTIONAL / SLED GUARDRAILS
- System prompt must include: "I provide general information only. This is not legal, financial, or medical advice."
- Content filtering enabled on OpenAI deployment (default Microsoft policy)
- Log request/response metadata for audit but never log full user message content (PII risk)
- Parameterize for Commercial vs Gov cloud (document gov cloud service availability assumptions)
- No secrets in source control — all config via environment variables

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
- [ ] Chatbot returns accurate, relevant answers to government service questions
- [ ] Responses include citations from the knowledge base
- [ ] Azure OpenAI connected using Managed Identity (no hardcoded keys)
- [ ] Infrastructure deployed via Bicep
- [ ] **Bonus:** Conversation history persists across page refreshes
- [ ] **Bonus:** Application Insights shows live telemetry
