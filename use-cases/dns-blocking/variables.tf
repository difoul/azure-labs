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

variable "allowed_domains" {
  type        = list(string)
  default     = ["difoul.io."]
  description = "Domain names (with trailing dot) to allow. All others are blocked."
}

variable "allowed_private_zones" {
  type        = list(string)
  default     = ["difoul.io"]
  description = "Private DNS zone names (without trailing dot) to create and link to the hub VNet."
}
