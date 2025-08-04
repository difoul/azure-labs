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
  type = string
  default = "176.138.150.80"
  nullable = false
}

variable "apache2-script" {
  type = string
  default = "c3VkbyBhcHQgdXBkYXRlIC15CnN1ZG8gYXB0IGluc3RhbGwgbmV0LXRvb2xzIC15CnN1ZG8gYXB0IGluc3RhbGwgYXBhY2hlMiAteQpzdWRvIGNob3duIC1SICRVU0VSOiRVU0VSIC92YXIvd3d3CmVjaG8gIjxoMz5IZWxsbyBmcm9tIHZpcnR1YWwgbWFjaGluZSA6IDwvaDM+IDxoMj48aT4kKGhvc3RuYW1lIC1pKTwvaT48L2gyPiIgPiBpbmRleC5odG1sCnN1ZG8gc3lzdGVtY3RsIHN0YXJ0IGFwYWNoZTIK"
  nullable = false
}