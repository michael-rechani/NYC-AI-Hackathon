# Contributing & Event Guide

![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-000000?logo=githubcopilot&logoColor=white)
![Microsoft Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?logo=microsoftazure&logoColor=white)
![Visual Studio Code](https://img.shields.io/badge/Visual_Studio_Code-007ACC?logo=visualstudiocode&logoColor=white)

Welcome to the NYC AI Hackathon. This guide covers how to get help during the event, how teams are structured, and how to make the most of your day.

---

## 🆘 Getting Help During the Event

Microsoft CSAs and SEs are on-site throughout the day. If you're stuck, here's the escalation path:

1. **Ask GitHub Copilot first** — paste the error directly into Copilot Chat. Most build and deployment errors can be resolved this way.
2. **Ask your table** — other teams may have hit the same issue. Compare notes.
3. **Flag a Microsoft CSA or SE** — they're circulating throughout the room. Raise your hand or find them at the front.

> For common issues (Azure login, subscription access, Bicep errors), check the troubleshooting section in your scenario README before escalating.

---

## 👥 Team Structure

- Teams of **2–4 people** are recommended
- All team members should have VS Code + GitHub Copilot installed and verified before the event starts
- One person should be the designated **Azure deployer** (runs `az login`, owns the subscription)
- Split work naturally: one person on infrastructure/Bicep, others on frontend/backend

---

## 🎯 Submitting Your Work

At the end of the event, each team will give a **5-minute demo** to the group. Your demo should show:

1. The running application on Azure (live URL or screen share)
2. One complete user flow (e.g., create a case, submit a permit, ask the chatbot a question)
3. A brief explanation of how GitHub Copilot helped you build it

There's no formal submission portal — the demo is your submission.

---

## 🏆 Evaluation Criteria

Judges will assess teams across four areas:

| Area | What they're looking for |
| --- | --- |
| **Functionality** | Does the app work end-to-end? Are the core features complete? |
| **Azure deployment** | Is the app running on Azure? Is infrastructure deployed via Bicep? |
| **Security** | No hardcoded secrets, Managed Identity used where applicable |
| **Copilot usage** | Did the team leverage Copilot effectively to accelerate development? |

Bonus points for CI/CD pipelines, Application Insights telemetry, and polished UI.

---

## 🔧 Contributing to This Repo

If you find a bug in a scenario prompt, a broken command, or want to suggest an improvement, open an issue or pull request on GitHub. Scenario prompts are continuously refined based on participant feedback.

When submitting a PR:

- Test your prompt changes by running them through GitHub Copilot Agent mode in a fresh folder
- Keep changes focused — one scenario per PR
- Include a brief description of what you changed and why
