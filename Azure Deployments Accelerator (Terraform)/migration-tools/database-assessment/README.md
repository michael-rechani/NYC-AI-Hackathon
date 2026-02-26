# Database Assessment Tools

This folder contains scripts and guidance for assessing databases for migration to Azure PaaS services using Microsoft's native tools.

## Tools Overview

### 1. Azure Data Studio with SQL Migration Extension (Primary Tool)
**Purpose**: Interactive GUI-based assessment and migration of SQL Server databases to Azure SQL Database, Azure SQL Managed Instance, or SQL Server on Azure VMs.

**Key Features**:
- Real-time compatibility assessment
- Feature parity analysis
- Performance recommendations
- Guided migration workflow
- Support for online and offline migrations

**Download**: 
- Azure Data Studio: https://aka.ms/azuredatastudio
- SQL Migration Extension: Install from Extensions marketplace in Azure Data Studio

### 2. Azure Database Migration Service (DMS) via PowerShell/CLI
**Purpose**: Automate database migrations from multiple sources to Azure data platforms with minimal downtime using command-line tools.

**Supported Sources**:
- SQL Server
- MySQL
- PostgreSQL
- MongoDB
- Oracle (preview)

**Target Platforms**:
- Azure SQL Database
- Azure SQL Managed Instance
- Azure Database for MySQL
- Azure Database for PostgreSQL
- Azure Cosmos DB

## Quick Start

### Option 1: Azure Data Studio with SQL Migration Extension (Recommended for Interactive Use)

1. **Install Azure Data Studio**
   ```powershell
   # Download and install Azure Data Studio
   .\install-azure-data-studio.ps1
   ```

2. **Enable SQL Migration Extension**
   - Open Azure Data Studio
   - Click Extensions icon (Ctrl+Shift+X)
   - Search for "Azure SQL Migration"
   - Click Install

3. **Run Assessment**
   - Right-click on SQL Server instance in Connections
   - Select "Manage"
   - Under "Azure SQL Migration", click "Migrate to Azure SQL"
   - Follow the wizard to assess and migrate

### Option 2: Azure DMS with PowerShell/CLI (Recommended for Automation)

1. **Install Azure PowerShell Module**
   ```powershell
   # Install the Azure DataMigration module
   .\install-azure-dms-module.ps1
   ```

2. **Run Automated Assessment**
   ```powershell
   # Use the assessment script
   .\run-dms-assessment.ps1 -ServerName "YourServerName" -DatabaseName "YourDatabaseName"
   ```

3. **Review Results**
   - Open the generated assessment report
   - Review compatibility issues
   - Check migration readiness
   - Plan migration strategy

### Setting up Azure Database Migration Service

1. **Prerequisites**
   - Azure subscription
   - Run assessments on all databases before migration
   - Use Azure Data Studio for interactive assessments
   - Use PowerShell/CLI for automated assessments at scale
   - Source database credentials
   - Target Azure SQL resource

2. **Create DMS Instance**
   ```powershell
   # Use the provided setup script
   .\setup-azure-dms.ps1 -ResourceGroup "YourRG" -Location "eastus"
   ```

3. **Configure Migration Project**
   - Create a migration project in Azure Data Studio or the Azure portal for Azure DMS
   - Select source/target types and provide credentials

## Best Practices

1. **Assessment Phase**
   - Run Azure Data Studio SQL Migration assessments on all databases before migration
   - Document all compatibility issues
   - Test migration on non-production first
   - Validate data integrity post-migration

2. **Migration Planning**
   - Schedule migrations during maintenance windows
   - Use online migration for minimal downtime
   - Keep source database as fallback
   - Plan for cutover procedures

3. **Post-Migration**
   - Update connection strings
   - Monitor performance
   - Optimize queries for Azure SQL
   - Update statistics and indexes

## Additional Resources
- [Azure Data Studio SQL Migration Extension](https://learn.microsoft.com/azure/dms/migration-using-azure-data-studio)
- [Azure DMS PowerShell Documentation](https://learn.microsoft.com/powershell/module/az.datamigration/)
- [Azure DMS CLI Documentation](https://learn.microsoft.com/cli/azure/datamigration)
- [Step-by-Step Assessment Guide](https://learn.microsoft.com/azure/dms/ads-sku-recommend)
- [Step-by-Step Migration Guide](https://learn.microsoft.com/azure/dms/migration-using-azure-data-studio)
- [Azure DMS Documentation](https://docs.microsoft.com/azure/dms/)
