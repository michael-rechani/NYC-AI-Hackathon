# Azure Migration Assessment Tools

A comprehensive toolkit for assessing and planning migrations to Azure PaaS services using Microsoft's native tools.

## Overview

This toolkit provides scripts, documentation, and workflows for assessing:
- **Databases** → Azure SQL Database, Azure SQL Managed Instance
- **Web Applications** → Azure App Service
- **Virtual/Physical Servers** → Azure VMs, App Service, or AKS

All tools in this kit are **Microsoft-native** and **officially supported**.

## Folder Structure

```
migration-tools/
├── database-assessment/     # Database migration tools
│   ├── README.md
│   ├── install-azure-data-studio.ps1
│   ├── install-azure-dms-module.ps1
│   ├── run-dms-assessment.ps1
│   └── setup-azure-dms.ps1
│
└── server-assessment/       # Server and app migration tools
    ├── README.md
    ├── install-app-service-migration-assistant.ps1
    ├── setup-azure-migrate.ps1
    └── install-azure-migrate-agent.ps1
```

## Quick Start Guide

### For Database Assessment & Migration

**Use Case**: Migrating SQL Server databases to Azure SQL

1. **Install Azure Data Studio** (GUI-based assessment)
   ```powershell
   .\database-assessment\install-azure-data-studio.ps1
   ```

2. **Or Install PowerShell Modules** (automation/scripting)
   ```powershell
   .\database-assessment\install-azure-dms-module.ps1
   ```

3. **Run Assessment**
   - In Azure Data Studio: Connect to SQL Server → Right-click → Manage → Azure SQL Migration
   - Via Script: `.\database-assessment\run-dms-assessment.ps1`

4. **Setup Migration Service**
   ```powershell
   .\database-assessment\setup-azure-dms.ps1 -ResourceGroupName "myRG" -Location "eastus"
   ```

**See**: [database-assessment/README.md](database-assessment/README.md)

---

### For Web Application Assessment & Migration

**Use Case**: Migrating IIS web apps to Azure App Service

1. **Install App Service Migration Assistant**
   ```powershell
   .\server-assessment\install-app-service-migration-assistant.ps1
   ```

2. **Run Assessment**
   - Launch App Service Migration Assistant
   - Select IIS site or enter website URL
   - Review compatibility report

3. **Migrate** (if compatible)
   - Follow wizard for one-click migration
   - Or export ARM templates for IaC

**See**: [server-assessment/README.md](server-assessment/README.md)

---

### For Server/VM Assessment & Migration

**Use Case**: Assessing physical or virtual servers for Azure migration

1. **Create Azure Migrate Project**
   ```powershell
   .\server-assessment\setup-azure-migrate.ps1 `
       -ResourceGroupName "myRG" `
       -ProjectName "ServerMigration" `
       -Location "eastus" `
       -CreateResourceGroup
   ```

2. **Choose Discovery Method**
   
   **Option A: Agentless (VMware/Hyper-V - Recommended)**
   - Download appliance from Azure Portal
   - Deploy to virtualization platform
   - Appliance auto-discovers servers
   
   **Option B: Agent-based (Physical servers)**
   ```powershell
   .\server-assessment\install-azure-migrate-agent.ps1 -ProjectKey "your-key"
   ```

3. **Create Assessment**
   - Wait for discovery (24-48 hours)
   - Azure Portal → Azure Migrate → Assess
   - Review readiness, sizing, cost estimates

**See**: [server-assessment/README.md](server-assessment/README.md)

## Migration Paths

### Databases
| Source | Target | Tool |
|--------|--------|------|
| SQL Server (on-premises) | Azure SQL Database | Azure Data Studio + DMS |
| SQL Server (on-premises) | Azure SQL Managed Instance | Azure Data Studio + DMS |
| SQL Server (VM) | Azure SQL | Azure Data Studio + DMS |
| MySQL/PostgreSQL | Azure Database for MySQL/PostgreSQL | Azure DMS |

### Applications
| Source | Target | Tool |
|--------|--------|------|
| IIS Web Apps (.NET) | Azure App Service | App Service Migration Assistant |
| Java (Tomcat) | Azure App Service | App Service Migration Assistant |
| ASP.NET Core | Azure App Service | App Service Migration Assistant |
| Containerizable Apps | Azure Kubernetes Service | App Containerization Tool |

### Servers
| Source | Target | Tool |
|--------|--------|------|
| VMware VMs | Azure VMs | Azure Migrate |
| Hyper-V VMs | Azure VMs | Azure Migrate |
| Physical Servers | Azure VMs | Azure Migrate |
| AWS/GCP VMs | Azure VMs | Azure Migrate |

## Prerequisites

### Software Requirements
- **Windows**: Windows 10/11 or Windows Server 2016+
- **PowerShell**: 5.1 or higher (or PowerShell 7+). Run scripts in an elevated prompt; if needed, use `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` for the session only.
- **Azure CLI**: (optional, for some scripts)
- **.NET Framework**: 4.7.2+ (for some tools)

### Azure Requirements
- Active Azure subscription
- Appropriate permissions to create resources
- Resource group for migration resources

### Network Requirements
- Internet connectivity to Azure
- Access to source systems (databases, servers, apps)
- Firewall rules for Azure Migrate appliance (if used)

## Best Practices

### Assessment Phase
1. **Start Small**: Begin with non-production workloads
2. **Collect Adequate Data**: Run assessments for 7-14 days for accurate sizing
3. **Document Everything**: Map dependencies, document configurations
4. **Test Thoroughly**: Validate in Azure before production cutover

### Migration Strategy
1. **Prefer PaaS over IaaS**: Use App Service instead of VMs when possible
2. **Phase Your Migration**: Don't migrate everything at once
3. **Maintain Rollback Plans**: Keep source systems available during transition
4. **Monitor Performance**: Track metrics before, during, and after migration

### Cost Optimization
1. **Right-size Resources**: Use assessment recommendations
2. **Choose Appropriate Tiers**: Don't over-provision
3. **Consider Reserved Instances**: For long-term workloads
4. **Review Regularly**: Optimize after migration based on actual usage

## Troubleshooting

### Common Issues

**Azure Data Studio won't connect to SQL Server**
- Check firewall rules
- Verify SQL Server allows remote connections
- Use SQL Server authentication if Windows auth fails

**App Service Migration Assistant shows compatibility issues**
- Review specific blockers in the report
- Check for unsupported features: https://learn.microsoft.com/azure/app-service/app-service-migration-assessment
- Consider modernization before migration

**Azure Migrate appliance not discovering servers**
- Verify network connectivity
- Check vCenter/Hyper-V credentials
- Review appliance logs in Azure Portal

## Support and Resources

### Official Documentation
- **Azure Database Migration Guide**: https://aka.ms/datamigration
- **Azure Migrate**: https://learn.microsoft.com/azure/migrate/
- **App Service Migration**: https://learn.microsoft.com/azure/app-service/app-service-migration-assessment
- **Azure DMS**: https://learn.microsoft.com/azure/dms/

### Getting Help
- **Azure Support**: https://azure.microsoft.com/support/
- **Q&A Forums**: https://learn.microsoft.com/answers/
- **GitHub Issues**: Report issues with these scripts

## What's Not Included

These tools do NOT cover:
- Third-party migration tools
- Deprecated/retired Microsoft tools (e.g., DMA)
- Custom migration scripts for specific scenarios
- Post-migration optimization (separate topic)

## Contributing

To add new scripts or improve existing ones:
1. Follow PowerShell best practices
2. Include comprehensive error handling
3. Add detailed documentation
4. Test thoroughly before committing

## License

These scripts are provided as-is for use with Microsoft Azure migration services.

---

**Last Updated**: January 2026  
**Tools Status**: All tools are currently supported by Microsoft
