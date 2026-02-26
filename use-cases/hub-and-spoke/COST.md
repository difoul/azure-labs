# Cost Estimation — hub-and-spoke

> Estimates based on **Sweden Central** pricing as of early 2026.
> All figures in **USD/month** at continuous 730-hour operation.
> Actual costs depend on data-transfer volumes and usage patterns.

## Summary

| Tier | Estimated monthly cost |
|---|---|
| Fixed infrastructure | ~$447 |
| Compute (3 VMs) | ~$23 |
| Storage & monitoring | ~$2 |
| **Total (lab baseline)** | **~$472 / month** |

The Azure Firewall accounts for **~95 %** of the fixed cost.

---

## Resource Breakdown

| Resource | SKU / Config | Count | Unit / Month | Monthly Cost |
|---|---|---|---|---|
| Azure Firewall | Standard | 1 | ~$445 | ~$445 |
| Azure Bastion | Developer SKU | 1 | Free | $0 |
| Log Analytics Workspace | PerGB2018 | 1 | $0 (< 5 GB/month free tier) | ~$0 |
| Storage Account (flow logs) | Standard LRS | 1 | ~$0.018/GB | ~$1 |
| Traffic Analytics | LAW-based | 1 | ~$0 (< 1 GB lab) | ~$1 |
| Network Watcher | — | 1 | Free | $0 |
| VM Standard_B1s (Linux) | 1 vCPU / 1 GiB | 3 | ~$7.59 | ~$23 |
| VNet (hub + 3 spokes) | — | 4 | Free | $0 |
| VNet Peering | Intra-region | 6 links | $0.01 / GB transferred | variable |
| NSG | — | 3 | Free | $0 |
| Route Tables | — | 3 | Free | $0 |
| Public IPs (Firewall) | Standard Static | 1 | ~$3.65 | ~$4 |

---

## Variable Costs

| Meter | Rate | Trigger |
|---|---|---|
| Firewall data processing | $0.016 / GB | All traffic traversing the firewall |
| VNet peering data transfer | $0.01 / GB | Cross-spoke traffic routed via hub |
| Log Analytics ingestion | $2.76 / GB | Beyond 5 GB/month free tier |
| Traffic Analytics ingestion | $2.76 / GB | VNet flow log data |
| VM disk (OS) | ~$1.54 / disk / month | Standard HDD 30 GiB — included in B1s |

---

## Cost Optimisation Tips

- **Biggest lever — the Firewall.** For dev/test workloads where security is not the focus, consider deploying a Basic SKU firewall (~$73/month) or removing it entirely and routing directly via peering.
- **Stop VMs when not in use.** Deallocating VMs stops compute billing; the managed disk (~$1.54/month) is the only remaining charge.
- **Disable flow logs** (`enable_flow_logs = false`) when not actively analysing traffic — saves storage and Traffic Analytics charges.
- **Bastion Developer SKU** is free and already used — no action needed.
