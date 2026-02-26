# Cost Estimation — dns-blocking

> Estimates based on **Sweden Central** pricing as of early 2026.
> All figures in **USD/month** at continuous 730-hour operation.
> DNS query costs depend heavily on query volume.

## Summary

| Tier | Estimated monthly cost |
|---|---|
| Fixed infrastructure | ~$445 |
| DNS Resolver & Security Policy | ~$11 |
| Monitoring (2 × LAW) | ~$0 |
| **Total (lab baseline)** | **~$456 / month** |

The Azure Firewall accounts for **~98 %** of the fixed cost.

---

## Resource Breakdown

| Resource | SKU / Config | Count | Unit / Month | Monthly Cost |
|---|---|---|---|---|
| Azure Firewall | Standard | 1 | ~$445 | ~$445 |
| Log Analytics Workspace (hub) | PerGB2018 | 1 | $0 (< 5 GB free tier) | ~$0 |
| Log Analytics Workspace (DNS) | PerGB2018 | 1 | $0 (< 5 GB free tier) | ~$0 |
| Network Watcher | — | 1 | Free | $0 |
| Private DNS Resolver | — | 1 | Free (endpoints billed separately) | $0 |
| DNS Resolver inbound endpoint | — | 1 | ~$5.11 ($0.007/hr) | ~$5 |
| DNS Resolver outbound endpoint | — | 1 | ~$5.11 ($0.007/hr) | ~$5 |
| DNS Security Policy | — | 1 | $0 base + per-query | ~$0 |
| DNS Security Rules | Allow + Block | 2 | $0 base + per-query | ~$0 |
| DNS Domain Lists | 2 lists | 2 | Free | $0 |
| Private DNS Zone (difoul.io) | — | 1 | ~$0.50 | ~$1 |
| VNet (hub) | — | 1 | Free | $0 |
| Public IP (Firewall) | Standard Static | 1 | ~$3.65 | ~$4 |

---

## Variable Costs

| Meter | Rate | Trigger |
|---|---|---|
| Firewall data processing | $0.016 / GB | All traffic traversing the firewall |
| DNS Security Policy queries | $0.15 / million queries | Each DNS query evaluated against rules |
| DNS Resolver queries | Included in endpoint pricing | — |
| Log Analytics ingestion | $2.76 / GB | DNS response logs beyond free tier |
| Private DNS queries | $0.40 / million queries | Queries hitting the private zone |

### Example query cost

| Scenario | Queries / day | Monthly DNS security cost |
|---|---|---|
| Lab (single workstation) | ~1 000 | < $0.01 |
| Small team (10 users) | ~100 000 | ~$0.45 |
| Enterprise (1 000 users) | ~10 000 000 | ~$45 |

---

## Cost Optimisation Tips

- **DNS Resolver endpoints** are the fixed cost at ~$10/month. They must be running for the security policy to function.
- **Security Policy query charges** are negligible at lab scale; they only become significant for high-throughput environments (millions of DNS queries/day).
- **Log ingestion** from DNS response diagnostics can grow quickly in production — consider a daily cap on the LAW or a lower retention period (currently 30 days).
- **Firewall** remains the dominant cost. The DNS resolver and security policy are inexpensive additions on top of an existing hub.
