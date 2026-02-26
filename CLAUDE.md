# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Infrastructure-as-Code (IaC) repository deploying Azure cloud infrastructure using Terraform. Demonstrates a Hub & Spoke enterprise network topology with integrated security, monitoring, and container services.

## Terraform Workflow

Each module (`network/`, `acr/`, `dns-securiy-policy/`) is deployed independently. Navigate into the module directory before running Terraform commands:

```bash
cd network/          # or acr/ or dns-securiy-policy/
terraform init
terraform plan
terraform apply
```

There are no Makefiles, CI/CD pipelines, linters, or automated tests — this is a purely manual Terraform workflow.

## Module Overview

| Module | Description |
|--------|-------------|
| `network/` | Primary Hub & Spoke deployment — the main module |
| `acr/` | Azure Container Registry with private endpoint and CMK encryption |
| `dns-securiy-policy/` | DNS resolver policy with domain allow/block rules (note: typo in folder name is intentional) |

## Architecture: Hub & Spoke

```
Hub VNet (10.0.0.0/16)
  └── Azure Firewall (AzureFirewallSubnet 10.0.0.0/24)
  └── Bastion Host
  └── Network Watcher / Flow Logs

Spoke-01 (10.1.0.0/16) — VMs, App Service, Private Endpoints
Spoke-02 (10.2.0.0/16) — VMs behind internal Load Balancer
Spoke-03 (10.3.0.0/16) — VMs (NSG controlled)
Shared Services (10.4.0.0/16) — Shared infrastructure
```

All spoke-to-hub peerings have `allow_forwarded_traffic = true` so that inter-spoke traffic routes through the Azure Firewall in the hub. The firewall policy currently allows all network traffic.

## Key Design Patterns

- **Resource naming**: Resources are suffixed with `var.product-name` (default `"net"` in `network/`, `"fbe"` elsewhere)
- **Default region**: `swedencentral`
- **Tags**: All resources tagged with `{ bu = "FBE" }`
- **Admin IP variable**: `my-public-ip` (used in NSG inbound rules to restrict SSH/RDP to a specific IP)
- **Credentials**: VM passwords are passed via `variables.tf` — the `dns-securiy-policy` module has a hardcoded example value `Pa55W@rd-53cr37` that should be replaced
- **`.gitignore`** excludes `*.tfvars`, `set-env-vars.sh`, `.terraform/`, and state files — use these for sensitive values

## DNS Security Policy Logic

The `dns-securiy-policy/` module implements a priority-based allow/block approach:
1. Priority 1000: Allow `difoul.io.` (private zone)
2. Priority 65000: Block all other domains (`*`)

The policy is linked to the hub VNet via the DNS resolver inbound endpoint.

## Monitoring (KQL Reference)

The `network/README.md` contains Kusto Query Language (KQL) queries for Log Analytics. Key query targets:
- `NTANetAnalytics` — VNet flow logs
- `AzureDiagnostics` — Firewall rule hits, ALB health events
- `AZFWNetworkRule`, `AZFWApplicationRule` — Firewall rule analytics

## Provider Versions

- `network/`: `azurerm = 4.38.1` (pinned)
- `acr/`: `azurerm ~> 4.0`
- `dns-securiy-policy/`: `azurerm` (unpinned) + `azapi` (for DNS resolver policy resources not yet in azurerm)
