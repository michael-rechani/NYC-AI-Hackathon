# Server and App Service Assessment Tools

This folder contains scripts and guidance for assessing physical/virtual servers and web applications for migration to Azure App Services and other Azure compute services.

## Tools Overview

### 1. Azure App Service Migration Assistant
**Purpose**: Assess and migrate on-premises web applications to Azure App Service.

**Supported Applications**:
- ASP.NET web applications
- .NET Core applications
- PHP applications
- Node.js applications
- Java applications (Tomcat)

**Key Features**:
- Automated compatibility assessment
- Identifies migration blockers
- Provides remediation guidance
- Supports direct migration to Azure App Service

**Download**: https://aka.ms/appservicemigrationassistant

### 2. Azure Migrate
**Purpose**: Comprehensive discovery, assessment, and migration of servers, databases, and applications to Azure.

**Assessment Capabilities**:
- Physical servers (Windows/Linux)
- VMware VMs
- Hyper-V VMs
- AWS/GCP VMs
- Web apps (IIS/Tomcat)
- SQL Server databases

**Key Features**:
- Agentless or agent-based discovery
- Dependency mapping
- Right-sizing recommendations
- Cost estimation
- Migration readiness assessment

**Access**: https://portal.azure.com/#blade/Microsoft_Azure_Migrate

### 3. Azure Migrate App Containerization Tool
**Purpose**: Containerize ASP.NET and Java web apps to run on Azure Kubernetes Service (AKS) or Azure Container Instances.

**Supported Apps**:
- ASP.NET apps on IIS
- Java apps on Tomcat

**Download**: Available through Azure Migrate portal

## Quick Start

### App Service Migration Assistant

1. **Install the Migration Assistant**
   ```powershell
   # Download and install
   .\install-app-service-migration-assistant.ps1
   ```

2. **Run Assessment**
   - Launch App Service Migration Assistant
   - Enter your website URL or select local IIS site
   - Review compatibility report
   - Follow migration steps if ready

3. **Migration Options**
   - Direct migration (one-click)
   - Manual migration with guidance
   - Export ARM templates for IaC deployment

### Azure Migrate for Server Assessment

1. **Setup Azure Migrate Project**
   ```powershell
   # Create Azure Migrate project
   .\setup-azure-migrate.ps1 -ResourceGroup "YourRG" -ProjectName "ServerMigration" -Location "eastus"
   ```

2. **Deploy Appliance (for VMware/Hyper-V)**
   - Download OVA/VHD from Azure portal
   - Deploy to your virtualization platform
   - Configure and register appliance

3. **Agentless Discovery (Recommended)**
   - Appliance discovers servers automatically
   - No agent installation needed on target servers

4. **View Assessment**
   - Azure portal shows discovered servers
   - Create assessment for Azure readiness
   - Review right-sizing and cost estimates

### For Physical Servers or Agent-Based Discovery

1. **Install Azure Migrate Agent**
   ```powershell
   # Install on each server to assess
   .\install-azure-migrate-agent.ps1 -ProjectKey "YourProjectKey" -WorkspaceId "YourWorkspaceId"
   ```

2. **Agent automatically collects:**
   - Server configuration
   - Performance metrics
   - Installed applications
   - Dependencies (optional)

## Assessment Workflow

### Web Applications to App Service

1. **Pre-Assessment**
   - Identify all web applications
   - Document current hosting environment
   - Note any dependencies (databases, file shares, etc.)

2. **Run Assessment**
   - Use App Service Migration Assistant on web server
   - Review compatibility issues
   - Check for unsupported features

3. **Address Issues**
   - Fix blocking issues
   - Plan workarounds for warnings
   - Update application configuration

4. **Migration Planning**
   - Choose App Service plan tier
   - Plan for database migration (if applicable)
   - Configure networking (VNet integration if needed)

### Physical/Virtual Servers to Azure VMs or App Service

1. **Discovery**
   - Deploy Azure Migrate appliance OR
   - Install agents on servers

2. **Assessment**
   - Create assessment in Azure Migrate
   - Review Azure readiness
   - Check right-sizing recommendations
   - Review cost estimates

3. **Decision**
   - Migrate to Azure VMs (IaaS) - lift and shift
   - Modernize to App Service (PaaS)
   - Containerize with AKS

4. **Migration**
   - Use Azure Migrate for VM migrations
   - Use App Service Migration Assistant for web apps
   - Use App Containerization for container migration

## Best Practices

1. **Assessment Phase**
   - Start with non-production environments
   - Run assessments during normal business hours to capture realistic performance data
   - Collect at least 7 days of performance data for accurate sizing
   - Map all dependencies before migration

2. **Web Application Assessment**
   - Test locally before attempting migration
   - Review web.config and app settings
   - Identify external dependencies
   - Check for custom modules or handlers

3. **Server Assessment**
   - Document all installed software
   - Identify licensing requirements
   - Check for specialized hardware requirements
   - Review backup and disaster recovery needs

4. **Migration Strategy**
   - Prefer PaaS (App Service) over IaaS (VMs) when possible
   - Use phased approach for large migrations
   - Maintain rollback plan
   - Test thoroughly in Azure before cutover

## Supported Migration Paths

### Web Applications
- **IIS Web Apps** → Azure App Service (Windows)
- **ASP.NET Core** → Azure App Service (Windows/Linux)
- **PHP/Node.js/Python** → Azure App Service (Linux)
- **Java (Tomcat)** → Azure App Service (Windows/Linux) or AKS

### Servers
- **Windows Server** → Azure VMs or Azure App Service
- **Linux Server** → Azure VMs or Azure App Service
- **VMware VMs** → Azure VMs
- **Hyper-V VMs** → Azure VMs
- **Physical Servers** → Azure VMs

## Additional Resources

- [Azure App Service Migration Assistant](https://aka.ms/appservicemigrationassistant)
- [Azure Migrate Documentation](https://learn.microsoft.com/azure/migrate/)
- [App Service Migration Best Practices](https://learn.microsoft.com/azure/app-service/app-service-migration-assessment)
- [Azure Migrate Tutorial](https://learn.microsoft.com/azure/migrate/tutorial-discover-vmware)
- [App Containerization Guide](https://learn.microsoft.com/azure/migrate/tutorial-app-containerization-aspnet-kubernetes)
