variable "location" {
  type        = string
  default     = "swedencentral"
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

variable "hub_vnet_id" {
  type        = string
  description = "Resource ID of the hub VNet; DNS resolver attaches here and the security policy VNet link targets it."
}

variable "inbound_subnet_id" {
  type        = string
  description = "Subnet ID for the DNS resolver inbound endpoint (must have Microsoft.Network/dnsResolvers delegation)."
}

variable "outbound_subnet_id" {
  type        = string
  description = "Subnet ID for the DNS resolver outbound endpoint (must have Microsoft.Network/dnsResolvers delegation)."
}

variable "allowed_domains" {
  type        = list(string)
  default     = ["difoul.io."]
  description = "Domain names (with trailing dot) to allow in the DNS security policy (priority 1000). All others are blocked (priority 65000)."
}

variable "allowed_private_zones" {
  type        = list(string)
  default     = ["difoul.io"]
  description = "Private DNS zone names (without trailing dot) to create and link to the hub VNet."
}
