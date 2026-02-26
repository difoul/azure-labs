```commandline
cat scripts/start-apache.sh | base64 -w0


NTANetAnalytics
| where TimeGenerated > ago(30min)
//| where FlowLogResourceId in ("113fce35-de27-4604-9936-5709a475333a/network-watcher-net-rg/network-watcher-net/vnet-flow-log-spoke-02")
| where FlowStatus == "Denied"
| project FlowStartTime, FlowEndTime, SrcIp, DestPort, DestIp, L4Protocol, L7Protocol, FlowDirection, FlowStatus, FlowType, SubType



NTANetAnalytics
| where TimeGenerated > ago(30min)
| where FlowStatus == "Denied"



AZFWNetworkRule 
| where TimeGenerated > ago(30min)
| where SourceIp in ("10.1.0.4") and DestinationIp in ("10.2.0.4", "10.2.0.5")

 ALBHealthEvent
| where TimeGenerated > ago(30min)
    | where HealthEventType == "SnatPortExhaustion"
    | summarize arg_max(TimeGenerated, *) by LoadBalancerResourceId, FrontendIP

ALBHealthEvent

NTAIpDetails 
| where TimeGenerated > ago(30min)

```