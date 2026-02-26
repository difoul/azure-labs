# Cost Estimation — container-app-private

> Estimates based on **Sweden Central** pricing as of early 2026.
> All figures in **USD/month** at continuous 730-hour operation unless noted.
> Container App costs are usage-based and shown separately.

## Summary

| Tier | Estimated monthly cost |
|---|---|
| Fixed infrastructure (hub + firewall) | ~$456 |
| Registry & Key Vault | ~$28 |
| Private networking | ~$16 |
| Management VM | ~$8 |
| **Total (infrastructure, idle app)** | **~$508 / month** |
| Container App (example: 1 replica, 0.5 vCPU / 1 GiB, running 8 h/day) | +~$4 |

The Azure Firewall accounts for **~88 %** of the total baseline cost.

---

## Resource Breakdown

### Hub & Networking

| Resource | SKU / Config | Count | Unit / Month | Monthly Cost |
|---|---|---|---|---|
| Azure Firewall | Standard | 1 | ~$445 | ~$445 |
| Log Analytics Workspace | PerGB2018 | 1 | $0 (< 5 GB free tier) | ~$0 |
| Network Watcher | — | 1 | Free | $0 |
| DNS Resolver inbound endpoint | — | 1 | ~$5.11 ($0.007/hr) | ~$5 |
| DNS Resolver outbound endpoint | — | 1 | ~$5.11 ($0.007/hr) | ~$5 |
| VNet (hub + spoke) | — | 2 | Free | $0 |
| VNet Peering | Intra-region | 2 links | $0.01 / GB transferred | variable |
| Public IP (Firewall) | Standard Static | 1 | ~$3.65 | ~$4 |

### Registry & Key Vault

| Resource | SKU / Config | Count | Unit / Month | Monthly Cost |
|---|---|---|---|---|
| Azure Container Registry | Premium | 1 | ~$20 base | ~$20 |
| ACR Private Endpoint | — | 1 | ~$7.30 | ~$7 |
| Private DNS Zone (ACR) | privatelink.azurecr.io | 1 | ~$0.50 | ~$1 |
| Key Vault | Standard + purge protection | 1 | ~$0.04 / key | ~$0 |
| Key Vault Private Endpoint | — | 1 | ~$7.30 | ~$7 |
| Private DNS Zone (KV) | privatelink.vaultcore.azure.net | 1 | ~$0.50 | ~$1 |

### Compute & Application

| Resource | SKU / Config | Count | Unit / Month | Monthly Cost |
|---|---|---|---|---|
| Container App Environment | Consumption workload profile | 1 | $0 base | $0 |
| Container App (0 min replicas, idle) | 0.5 vCPU / 1 GiB | 1 | $0 when no replicas | ~$0 |
| Management VM | Standard_B1s (1 vCPU / 1 GiB) | 1 | ~$7.59 | ~$8 |
| User-assigned Managed Identity | — | 1 | Free | $0 |

---

## Container App Variable Costs

The Container App uses the **Consumption** workload profile — you pay only for active replicas.

| Meter | Rate |
|---|---|
| vCPU-second | $0.000024 |
| GiB-second | $0.000003 |

### Example monthly costs (0.5 vCPU / 1 GiB container)

| Usage pattern | Active hours / day | Replicas | Monthly cost |
|---|---|---|---|
| Idle (min_replicas = 0) | 0 | 0 | **$0** |
| Dev/test | 8 h / day | 1 | **~$4** |
| Business hours | 12 h / day | 1 | **~$6** |
| Always-on | 24 h / day | 1 | **~$13** |
| Always-on + redundancy | 24 h / day | 3 | **~$39** |

---

## Variable Costs

| Meter | Rate | Trigger |
|---|---|---|
| Firewall data processing | $0.016 / GB | Egress / inter-VNet traffic through firewall |
| VNet peering data transfer | $0.01 / GB | Spoke-to-hub traffic (ACR pulls, etc.) |
| ACR image storage | $0.003 / GiB-day | Stored image layers |
| ACR data transfer (pull) | $0.08 / GB (outbound) | Image pulls from outside Azure |
| Key Vault operations | $0.005 / 10 000 ops | CMK encrypt / decrypt by ACR |
| Log Analytics ingestion | $2.76 / GB | Beyond 5 GB/month free tier |

---

## Cost Optimisation Tips

- **Stop the management VM** when not in use — deallocating stops compute billing, only the managed disk (~$1.54/month) remains.
- **Set `min_replicas = 0`** (already the default) — the Container App scales to zero when idle, incurring zero compute cost.
- **ACR Premium** is required for private endpoints. If the private endpoint is removed (public-only access), Standard SKU (~$10/month) is sufficient.
- **DNS Resolver** (~$10/month) is required for spoke-to-hub private DNS resolution. It can be replaced with per-spoke DNS zone VNet links at no additional cost if the number of spokes is small.
- **Firewall** remains the dominant cost driver (~88 %). For a pure lab, replacing it with simple peering (no UDR) eliminates ~$445/month but removes centralized traffic inspection.
