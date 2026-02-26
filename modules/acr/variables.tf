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
  description = "Resource ID of the hub VNet; used to link the ACR private DNS zone."
}

variable "endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the ACR private endpoint."
}

variable "key_vault_id" {
  type        = string
  description = "Resource ID of the Key Vault (from modules/key-vault). Used to grant Key Vault Crypto User to the ACR identity."
}

variable "key_vault_key_id" {
  type        = string
  description = "Versionless ID of the CMK key (from modules/key-vault). Used for ACR encryption."
}

variable "enable_abac" {
  type        = bool
  default     = false
  description = "Enable ABAC (Attribute-Based Access Control) repository-level permissions on the ACR. Sets roleAssignmentMode = 'AbacRepositoryPermissions' via azapi_update_resource (API 2025-11-01)."
}

variable "repositories" {
  type = map(object({
    pull_principal_ids = optional(list(string), [])
    push_principal_ids = optional(list(string), [])
  }))
  default     = {}
  description = <<-EOT
    Map of repository name to principal IDs for ABAC-scoped role assignments.
    Only effective when enable_abac = true.
      - pull_principal_ids : assigned Container Registry Repository Reader (scoped to this repo)
      - push_principal_ids : assigned Container Registry Repository Writer (scoped to this repo, includes pull)
    Example:
      repositories = {
        "myapp/backend" = {
          pull_principal_ids = ["<principal-id-1>"]
          push_principal_ids = ["<principal-id-2>"]
        }
      }
  EOT
}

variable "geo_replication_locations" {
  type = list(object({
    location                  = string
    zone_redundancy_enabled   = optional(bool, false)
    regional_endpoint_enabled = optional(bool, false)
  }))
  default     = []
  description = "Optional list of geo-replication regions for the ACR Premium registry."
}
