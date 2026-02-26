variable "location" {
  type        = string
  default     = "swedencentral"
  description = "Azure region for all resources."
}

variable "product-name" {
  type        = string
  default     = "fbe"
  description = "Project/Application name suffix applied to all resource names."
}

variable "tags" {
  type = map(string)
  default = {
    bu = "FBE"
  }
  description = "Tags applied to all resources."
}

variable "deployer_ip_rules" {
  type        = list(string)
  default     = []
  description = "Your public IP(s) in CIDR notation (e.g. [\"1.2.3.4/32\"]) allowed to reach the Key Vault during terraform apply."
}

variable "enable_abac" {
  type        = bool
  default     = false
  description = "Enable ABAC repository-level permissions on the ACR."
}

variable "repositories" {
  type = map(object({
    pull_principal_ids = optional(list(string), [])
    push_principal_ids = optional(list(string), [])
  }))
  default     = {}
  description = "Repository-scoped ABAC role assignments. Only effective when enable_abac = true."
}

variable "geo_replication_locations" {
  type = list(object({
    location                  = string
    zone_redundancy_enabled   = optional(bool, false)
    regional_endpoint_enabled = optional(bool, false)
  }))
  default     = []
  description = "Optional geo-replication locations for ACR."
}
