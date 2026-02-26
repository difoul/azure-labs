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
  description = "Resource ID of the hub VNet; used to link the private DNS zone."
}

variable "endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the Key Vault private endpoint."
}

variable "deployer_ip_rules" {
  type        = list(string)
  default     = []
  description = <<-EOT
    Public IP addresses or CIDR ranges allowed to reach the Key Vault data plane
    during Terraform operations (key creation, rotation policy). Required because
    the vault uses default_action = Deny; AzureServices bypass only covers trusted
    Azure services, not the deploying workstation or CI/CD runner.
    Example: ["176.138.150.80/32"]
  EOT
}

variable "kv_name_override" {
  type        = string
  default     = null
  description = "Override the Key Vault name. Defaults to 'kv-{product-name}'. Must be globally unique, 3-24 alphanumeric/hyphen chars."
}

variable "key_name" {
  type        = string
  default     = "cmk-key"
  description = "Name of the CMK key to create inside the Key Vault."
}

variable "key_type" {
  type        = string
  default     = "RSA"
  description = "Key type for the CMK key (RSA or EC)."
}

variable "key_size" {
  type        = number
  default     = 2048
  description = "Key size in bits. Applicable when key_type = 'RSA'."
}
