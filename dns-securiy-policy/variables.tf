variable "location" {
  type        = string
  default     = "swedencentral"
  description = "Azure resources location"
}

variable "product-name" {
  type        = string
  default     = "fbe"
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

variable "pwd" {
  type    = string
  default = "Pa55W@rd-53cr37"
}