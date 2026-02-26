variable "location" {
  type        = string
  default     = "swedencentral"
  description = "Azure region for all resources."
}

variable "product-name" {
  type        = string
  default     = "net"
  description = "Project/Application name suffix applied to all resource names."
}

variable "tags" {
  type = map(string)
  default = {
    bu = "FBE"
  }
  description = "Tags applied to all resources."
}

variable "admin_ip" {
  type        = string
  default     = ""
  description = "Your public IP (CIDR notation, e.g. '1.2.3.4/32') for NSG inbound allow rules."
}
