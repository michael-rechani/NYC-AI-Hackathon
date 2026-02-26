# Architecture Overview

This document describes the architecture of the three deployment options available in this repository.

## Architecture Diagrams

### Hub Infrastructure

```text
┌─────────────────────────────────────────────────────────────┐
│ Azure Region (e.g., East US)                                │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Resource Group: rg-hub                              │   │
│  │                                                       │   │
│  │  ┌────────────────────────────────────────────────┐ │   │
│  │  │ Virtual Network: vnet-hub                      │ │   │
│  │  │ Address Space: 10.0.0.0/16                     │ │   │
│  │  │                                                 │ │   │
│  │  │  ┌────────────────────────────────────────┐   │ │   │
│  │  │  │ AzureBastionSubnet (10.0.1.0/26)       │   │ │   │
│  │  │  │                                         │   │ │   │
│  │  │  │  ┌──────────────────────────────────┐ │   │ │   │
│  │  │  │  │ Azure Bastion (Standard SKU)     │ │   │ │   │
│  │  │  │  │ - Secure RDP/SSH Access          │ │   │ │   │
│  │  │  │  │ - Tunneling & IP Connect         │ │   │ │   │
│  │  │  │  │ - Public IP: Standard SKU        │ │   │ │   │
│  │  │  │  └──────────────────────────────────┘ │   │ │   │
│  │  │  └────────────────────────────────────────┘   │ │   │
│  │  │                                                 │ │   │
│  │  │  ┌────────────────────────────────────────┐   │ │   │
│  │  │  │ Jumpbox Subnet (10.0.2.0/24)           │   │ │   │
│  │  │  │ → NAT Gateway (outbound internet)      │   │ │   │
│  │  │  │                                         │   │ │   │
│  │  │  │  ┌──────────────────────────────────┐ │   │ │   │
│  │  │  │  │ Windows VM (Jumpbox)             │ │   │ │   │
│  │  │  │  │ - Windows Server 2022            │ │   │ │   │
│  │  │  │  │ - Private IP only                │ │   │ │   │
│  │  │  │  │ - Access via Bastion             │ │   │ │   │
│  │  │  │  └──────────────────────────────────┘ │   │ │   │
│  │  │  └────────────────────────────────────────┘   │ │   │
│  │  │                                                 │ │   │
│  │  │  ┌────────────────────────────────────────┐   │ │   │
│  │  │  │ Private Endpoint Subnet (10.0.3.0/24)  │   │ │   │
│  │  │  │                                         │   │ │   │
│  │  │  │  ┌──────────────────────────────────┐ │   │ │   │
│  │  │  │  │ Key Vault Private Endpoint       │ │   │ │   │
│  │  │  │  └──────────────────────────────────┘ │   │ │   │
│  │  │  └────────────────────────────────────────┘   │ │   │
│  │  └────────────────────────────────────────────────┘ │   │
│  │                                                       │   │
│  │  ┌────────────────────────────────────────────────┐ │   │
│  │  │ Azure Key Vault                                │ │   │
│  │  │ - Stores all VM/SQL credentials                │ │   │
│  │  │ - Private Endpoint in PE subnet                │ │   │
│  │  │ - Firewall: Deny by default                    │ │   │
│  │  │ - Access policies for Terraform executor       │ │   │
│  │  └────────────────────────────────────────────────┘ │   │
│  │                                                       │   │
│  │  ┌────────────────────────────────────────────────┐ │   │
│  │  │ Private DNS Zone                               │ │   │
│  │  │ - privatelink.vaultcore.azure.net              │ │   │
│  │  │ - Linked to hub, iaas, and paas VNets          │ │   │
│  │  └────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### IaaS Deployment (Web + SQL VMs)

```text
┌─────────────────────────────────────────────────────────────────────┐
│ Azure Region (e.g., East US)                                        │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Resource Group: rg-iaas                                         │ │
│  │                                                                  │ │
│  │  ┌────────────────────────────────────────────────────────┐   │ │
│  │  │ Virtual Network: vnet-iaas                             │   │ │
│  │  │ Address Space: 10.1.0.0/16                             │   │ │
│  │  │ ←── VNet Peering ──→ vnet-hub (10.0.0.0/16)           │   │ │
│  │  │                                                         │   │ │
│  │  │  ┌──────────────────────────────────────────────────┐ │   │ │
│  │  │  │ Web Subnet (10.1.1.0/24)                         │ │   │ │
│  │  │  │ → NAT Gateway (outbound internet)                │ │   │ │
│  │  │  │                                                   │ │   │ │
│  │  │  │  ┌─────────────────────────────────────────────┐│ │   │ │
│  │  │  │  │ Web Server VM                               ││ │   │ │
│  │  │  │  │ - Windows Server 2022                       ││ │   │ │
│  │  │  │  │ - IIS Ready                                 ││ │   │ │
│  │  │  │  │ - Public IP (Optional)                      ││ │   │ │
│  │  │  │  │ - Private IP: 10.1.1.x                      ││ │   │ │
│  │  │  │  └─────────────────────────────────────────────┘│ │   │ │
│  │  │  │                                                   │ │   │ │
│  │  │  │  NSG Rules:                                      │ │   │ │
│  │  │  │  - Allow HTTP (80)                               │ │   │ │
│  │  │  │  - Allow HTTPS (443)                             │ │   │ │
│  │  │  └──────────────────────────────────────────────────┘ │   │ │
│  │  │                                                         │   │ │
│  │  │            ↓ SQL Connection                             │   │ │
│  │  │                                                         │   │ │
│  │  │  ┌──────────────────────────────────────────────────┐ │   │ │
│  │  │  │ Data Subnet (10.1.2.0/24)                        │ │   │ │
│  │  │  │ → NAT Gateway (outbound internet)                │ │   │ │
│  │  │  │                                                   │ │   │ │
│  │  │  │  ┌─────────────────────────────────────────────┐│ │   │ │
│  │  │  │  │ SQL Server VM                               ││ │   │ │
│  │  │  │  │ - SQL Server 2022                           ││ │   │ │
│  │  │  │  │ - Data Disk (256 GB Premium)                ││ │   │ │
│  │  │  │  │ - Log Disk (128 GB Premium)                 ││ │   │ │
│  │  │  │  │ - Private IP only: 10.1.2.x                 ││ │   │ │
│  │  │  │  └─────────────────────────────────────────────┘│ │   │ │
│  │  │  │                                                   │ │   │ │
│  │  │  │  NSG Rules:                                      │ │   │ │
│  │  │  │  - Allow SQL (1433) from Web Subnet only        │ │   │ │
│  │  │  └──────────────────────────────────────────────────┘ │   │ │
│  │  └────────────────────────────────────────────────────────┘   │ │
│  │                                                                  │ │
│  │  DNS: Linked to hub's privatelink.vaultcore.azure.net zone      │ │
│  │  Credentials stored in hub Key Vault via VNet peering           │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### PaaS Deployment (App Service + Azure SQL)

```text
┌──────────────────────────────────────────────────────────────────────────┐
│ Azure Region (e.g., East US)                                             │
│                                                                            │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ Resource Group: rg-paas                                           │   │
│  │                                                                    │   │
│  │  ┌───────────────────────────────────────────────────────────┐  │   │
│  │  │ Virtual Network: vnet-paas (10.2.0.0/16)                  │  │   │
│  │  │ ←── VNet Peering ──→ vnet-hub (10.0.0.0/16)               │  │   │
│  │  │                                                            │  │   │
│  │  │  ┌────────────────────────────────────────────────────┐  │  │   │
│  │  │  │ App Service Subnet (10.2.1.0/24)                   │  │  │   │
│  │  │  │ - Delegated to Microsoft.Web/serverFarms           │  │  │   │
│  │  │  │ → NAT Gateway (outbound internet)                  │  │  │   │
│  │  │  └────────────────────────────────────────────────────┘  │  │   │
│  │  │  ┌────────────────────────────────────────────────────┐  │  │   │
│  │  │  │ Private Endpoint Subnet (10.2.2.0/24)              │  │  │   │
│  │  │  │ - SQL Server Private Endpoint                      │  │  │   │
│  │  │  │ - App Service Private Endpoint                     │  │  │   │
│  │  │  └────────────────────────────────────────────────────┘  │  │   │
│  │  └───────────────────────────────────────────────────────────┘  │   │
│  │                                                                    │   │
│  │  ┌───────────────────────────────────────────────────────────┐  │   │
│  │  │ App Service Plan (asp-paas)                               │  │   │
│  │  │ - SKU: S1 (Standard) or P1v3 (Production)                │  │   │
│  │  │ - Windows or Linux                                         │  │   │
│  │  └───────────────────────────────────────────────────────────┘  │   │
│  │                                                                    │   │
│  │  ┌───────────────────────────────────────────────────────────┐  │   │
│  │  │ App Service (app-paas)                                     │  │   │
│  │  │ - Runtime: .NET, Node.js, Python, etc.                    │  │   │
│  │  │ - HTTPS Only, Private Endpoint                            │  │   │
│  │  │ - VNet Integration                                         │  │   │
│  │  │ - Connection String to SQL                                │  │   │
│  │  └───────────────────────────────────────────────────────────┘  │   │
│  │                                                                    │   │
│  │                       ↓ SQL Connection (Private Endpoint)         │   │
│  │                                                                    │   │
│  │  ┌───────────────────────────────────────────────────────────┐  │   │
│  │  │ Azure SQL Server (sql-paas.database.windows.net)          │  │   │
│  │  │ - Version: 12.0                                            │  │   │
│  │  │ - Private Endpoint in PE subnet                           │  │   │
│  │  │ - Public access disabled                                   │  │   │
│  │  │                                                            │  │   │
│  │  │  ┌───────────────────────────────────────────────────┐   │  │   │
│  │  │  │ SQL Database (sqldb-app) - Serverless GP_S_Gen5   │   │  │   │
│  │  │  │ - Auto-pause enabled                              │   │  │   │
│  │  │  │ - Max Size: 32 GB (configurable)                  │   │  │   │
│  │  │  └───────────────────────────────────────────────────┘   │  │   │
│  │  └───────────────────────────────────────────────────────────┘  │   │
│  │                                                                    │   │
│  │  ┌───────────────────────────────────────────────────────────┐  │   │
│  │  │ Application Insights                                       │  │   │
│  │  │ - Application performance monitoring                       │  │   │
│  │  │ - Integrated with App Service                             │  │   │
│  │  └───────────────────────────────────────────────────────────┘  │   │
│  │                                                                    │   │
│  │  DNS: Linked to hub's privatelink.vaultcore.azure.net zone       │   │
│  │  Credentials stored in hub Key Vault via VNet peering            │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────┘
```

## Deployment Patterns

### Pattern 1: Development Environment

**Characteristics:**

- Low cost
- Basic SKUs
- Public access
- No redundancy

**Configuration:**

```text
Hub:
  - Bastion: Basic SKU
  - Jumpbox: Standard_B2s VM

IaaS:
  - Web VM: Standard_B2ms
  - SQL VM: Standard_E2s_v3
  - No public IPs

PaaS:
  - App Service Plan: B1
  - SQL Database: Basic or S0
  - No private endpoints
```

### Pattern 2: Production Environment

**Characteristics:**

- High availability
- Premium SKUs
- Private networking
- Zone redundancy

**Configuration:**

```text
Hub:
  - Bastion: Standard SKU
  - Jumpbox: Standard_D2s_v3

IaaS:
  - Web VM: Standard_D4s_v3 (multiple zones)
  - SQL VM: Standard_E4s_v3 + managed disks
  - Load Balancer for web tier

PaaS:
  - App Service Plan: P2v3 or P3v3
  - SQL Database: P1 or Business Critical
  - Private Endpoints enabled
  - Zone redundancy enabled
```

### Pattern 3: Hybrid Environment (Hub + IaaS + PaaS)

**Characteristics:**

- Hub-and-spoke network topology
- Centralized Key Vault and Bastion
- VNet peering between all layers
- Private DNS resolution across all VNets

**Configuration:**

```text
1. Deploy hub infrastructure (Key Vault, Bastion, Private DNS)
2. Deploy IaaS workloads with VNet peering to hub
3. Deploy PaaS workloads with VNet peering to hub
4. All layers share Key Vault for secrets via private endpoint
```

## Security Architecture

### Network Security

1. **Network Segmentation**
   - Separate subnets for each tier
   - Network Security Groups (NSGs) on each subnet
   - Bastion for secure VM access

2. **Firewall Rules**
   - IaaS: NSG rules allow only necessary traffic
   - PaaS: SQL firewall configured for Azure services
   - No direct internet access to data tier

3. **Private Connectivity**
   - Optional Private Endpoints for SQL Server
   - VNet Integration for App Service
   - ExpressRoute/VPN for hybrid scenarios

### Identity and Access

1. **Azure AD Integration**
   - Use managed identities where possible
   - Azure AD authentication for SQL Database
   - RBAC for resource access

2. **Secrets Management**
   - Store passwords in Azure Key Vault
   - Reference secrets from App Service
   - Rotate secrets regularly

### Data Protection

1. **Encryption**
   - HTTPS only for App Service
   - TLS 1.2 minimum
   - Transparent Data Encryption (TDE) for SQL
   - Encryption at rest for VM disks

2. **Backup and DR**
   - Azure Backup for VMs
   - Automated backups for SQL Database
   - Geo-redundancy for critical databases

## Monitoring and Management

### Application Insights

- Integrated with App Service
- Application performance monitoring
- Dependency tracking
- Custom metrics and logs

### Azure Monitor

- VM insights for IaaS resources
- Log Analytics workspace
- Alerts and action groups
- Dashboards for visualization

### Cost Management

- Resource tagging for cost allocation
- Azure Cost Management + Billing
- Budget alerts
- Right-sizing recommendations

## Scalability

### IaaS Scaling

- **Vertical**: Resize VM SKUs
- **Horizontal**: Add more VMs with Load Balancer
- **Auto-scaling**: VM Scale Sets (advanced)

### PaaS Scaling

- **Vertical**: Change App Service Plan SKU
- **Horizontal**: Scale out instances
- **Auto-scaling**: Built-in auto-scale rules

## High Availability

### IaaS HA

- Availability Zones
- Availability Sets
- Load Balancers
- SQL Always On (advanced)

### PaaS HA

- App Service built-in HA
- SQL Database active geo-replication
- Zone redundancy
- Multi-region deployment

## Disaster Recovery

### IaaS DR

- Azure Site Recovery for VMs
- SQL Server backup to Azure Storage
- Cross-region replication

### PaaS DR

- SQL Database geo-restore
- App Service deployment slots
- Traffic Manager for failover

## Cost Optimization

### Development Environment

- Use B-series VMs
- Basic/Standard SQL tiers
- Shared App Service Plan
- Auto-shutdown for VMs

**Estimated Monthly Cost**: $200-400

### Production Environment

- Reserved Instances for VMs
- SQL Database reserved capacity
- Premium App Service Plan
- Monitor and optimize unused resources

**Estimated Monthly Cost**: $1,000-3,000

## Compliance and Governance

- Azure Policy for governance
- Resource locks for protection
- Compliance certifications
- Audit logging enabled

## Best Practices

1. **Infrastructure as Code**: All infrastructure defined in Terraform
2. **Version Control**: Track changes in Git
3. **Testing**: Test in dev before prod
4. **Documentation**: Keep architecture docs updated
5. **Automation**: Use CI/CD for deployments
6. **Monitoring**: Enable comprehensive monitoring
7. **Security**: Follow Azure Security Benchmark
8. **Cost**: Regular cost reviews and optimization
