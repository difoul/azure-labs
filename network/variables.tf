variable "location" {
  type        = string
  default     = "swedencentral"
  description = "Azure resources location"
}

variable "product-name" {
  type        = string
  default     = "net"
  nullable    = false
  description = "(Mandatory) Project/Application name."
}

variable "tags" {
  type = map(string)
  default = {
    bu = "FBE"
  }
  description = "Mandatory tags"
}

variable "my-public-ip" {
  type     = string
  default  = "176.138.150.80"
  nullable = false
}

variable "pwd" {
  type     = string
  default  = "xxxxxxxxxxx"
  nullable = false
}