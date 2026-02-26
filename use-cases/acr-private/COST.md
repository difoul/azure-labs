# Cost Estimation — acr-private

> Estimates based on **Sweden Central** pricing as of early 2026.
> All figures in **USD/month** at continuous 730-hour operation.
> Actual costs depend on image storage size, pull frequency, and geo-replication.

## Summary

| Tier | Estimated monthly cost |
|---|---|
| Fixed infrastructure | ~$445 |
| Registry & Key Vault | ~$28 |
| Private networking | ~$16 |
| **Total (lab baseline)** | **~$489 / month** |

The Azure Firewall accounts for **~91 %** of the fixed cost.

---

## Resource Breakdown

| Resource | SKU / Config | Count | Unit / Month | Monthly Cost |
|---|---|---|---|---|
| Azure Firewall | Standard | 1 | ~$445 | ~$445 |
| Log Analytics Workspace | PerGB2018 | 1 | $0 (< 5 GB/month free tier) | ~$0 |
| Network Watcher | — | 1 | Free | $0 |
| Azure Container Registry | Premium | 1 | ~$20 base | ~$20 |
| ACR image storage | — | — | $0.003 / GiB-day | variable |
| ACR Private Endpoint | — | 1 | ~$7.30 | ~$7 |
| Private DNS Zone (ACR) | privatelink.azurecr.io | 1 | ~$0.50 | ~$1 |
| Key Vault | Standard + purge protection | 1 | ~$0.04 / key | ~$0 |
| Key Vault Private Endpoint | — | 1 | ~$7.30 | ~$7 |
| Private DNS Zone (KV) | privatelink.vaultcore.azure.net | 1 | ~$0.50 | ~$1 |
| VNet (hub) | — | 1 | Free | $0 |
| Public IP (Firewall) | Standard Static | 1 | ~$3.65 | ~$4 |

---

## Variable Costs

| Meter | Rate | Trigger |
|---|---|---|
| Firewall data processing | $0.016 / GB | Egress traffic from the hub |
| ACR image storage | $0.003 / GiB-day (~$0.09 / GiB-month) | Stored image layers |
| ACR data transfer (pull) | $0.08 / GB (outbound) | Image pulls from outside Azure |
| ACR geo-replication | ~$20 / replica / month (Premium) | Each additional region enabled |
| Key Vault operations | $0.005 / 10 000 ops | Key use by ACR encryption |
| Log Analytics ingestion | $2.76 / GB | Beyond 5 GB/month free tier |
| Private DNS queries | $0.40 / million queries | DNS lookups for private endpoints |

---

## Cost Optimisation Tips

- **ACR Premium is required** for private endpoints and zone redundancy. Downgrading to Standard removes private endpoint support.
- **Geo-replication** adds ~$20/month per replica region — enable only when cross-region resilience is needed.
- **Key Vault operations** are near zero in a lab; costs only become meaningful at scale (millions of encrypt/decrypt calls/day).
- **Firewall** is the largest cost driver. See `hub-and-spoke/COST.md` for optimisation options.
- **ABAC role assignments** (`enable_abac = true`) have no additional Azure cost beyond the role-assignment limit (2 000 per scope).
