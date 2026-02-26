variable "location" {
  type        = string
  description = "Azure region for all resources."
}

variable "product-name" {
  type        = string
  nullable    = false
  description = "Project/Application name suffix applied to all resource names."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources."
}

variable "spoke_name" {
  type        = string
  description = "Short name for this spoke (e.g. 'spoke-01'). Used in resource names."
}

variable "spoke_address_space" {
  type        = string
  description = "CIDR address space for the spoke VNet."
}

variable "subnets" {
  type = map(object({
    cidr                                      = string
    private_endpoint_network_policies_enabled = optional(bool, false)
    delegation_name                           = optional(string)
    service_delegation_name                   = optional(string)
    service_delegation_actions                = optional(list(string), [])
  }))
  description = "Map of subnet name to subnet configuration. Delegated subnets are excluded from NSG association."
}

variable "admin_ip" {
  type        = string
  default     = ""
  description = "Your public IP address (CIDR notation) for an NSG inbound allow-all rule. Leave empty to skip."
}

variable "hub_vnet_id" {
  type        = string
  description = "Resource ID of the hub VNet for VNet peering."
}

variable "hub_vnet_name" {
  type        = string
  description = "Name of the hub VNet for hub-to-spoke peering."
}

variable "hub_resource_group_name" {
  type        = string
  description = "Resource group name of the hub VNet for hub-to-spoke peering."
}

variable "firewall_private_ip" {
  type        = string
  description = "Private IP of the Azure Firewall; used as next-hop in the spoke route table."
}

variable "custom_dns_servers" {
  type        = list(string)
  default     = []
  description = "Custom DNS server IPs for the spoke VNet. Set to the hub DNS Resolver inbound endpoint IP so spoke workloads resolve hub-linked private DNS zones (e.g. privatelink.azurecr.io)."
}

variable "nsg_rules" {
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string, "*")
    destination_port_range       = optional(string, "*")
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
  default     = []
  description = "Additional NSG security rules. Use either *_prefix (string) or *_prefixes (list), not both."
}
