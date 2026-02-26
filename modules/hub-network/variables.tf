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
  default     = { bu = "FBE" }
  description = "Tags applied to all resources."
}

variable "hub_address_space" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR address space for the hub VNet."
}

variable "firewall_subnet_cidr" {
  type        = string
  default     = "10.0.0.0/24"
  description = "CIDR for AzureFirewallSubnet (must be /26 or larger)."
}

variable "endpoint_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR for the private endpoints subnet in the hub VNet."
}

variable "enable_bastion" {
  type        = bool
  default     = false
  description = "Whether to deploy Azure Bastion (Developer SKU) in the hub VNet."
}

variable "enable_flow_logs" {
  type        = bool
  default     = false
  description = "Whether to enable VNet flow logs with traffic analytics on the hub VNet."
}

variable "enable_dns_resolver_subnets" {
  type        = bool
  default     = false
  description = "Create DNS resolver inbound/outbound subnets only. Use when an external module (e.g. dns-security) manages the resolver resource itself."
}

variable "enable_dns_resolver" {
  type        = bool
  default     = false
  description = "Create DNS resolver inbound/outbound subnets AND the Private DNS Resolver with its endpoints. Use when the hub should own DNS forwarding for spoke VNets. Mutually exclusive with enable_dns_resolver_subnets."
}

variable "inbound_dns_subnet_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR for the DNS resolver inbound endpoint subnet. Used when enable_dns_resolver_subnets = true."
}

variable "outbound_dns_subnet_cidr" {
  type        = string
  default     = "10.0.3.0/24"
  description = "CIDR for the DNS resolver outbound endpoint subnet. Used when enable_dns_resolver_subnets = true."
}

