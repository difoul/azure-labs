variable "location" {
  type        = string
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

variable "resource_group_name" {
  type        = string
  description = "Existing resource group name to deploy VMs into."
}

variable "vm_subnet_id" {
  type        = string
  description = "Subnet ID for VM network interfaces."
}

variable "vm_count" {
  type        = number
  default     = 1
  description = "Number of Linux VMs to deploy."
}

variable "vm_size" {
  type        = string
  default     = "Standard_B1s"
  description = "VM SKU size."
}

variable "vm_name_prefix" {
  type        = string
  description = "Prefix for VM and NIC names (e.g. 'vmspk01'). Count index is appended."
}

variable "admin_username" {
  type        = string
  default     = "adminuser"
  description = "Admin username for the VMs."
}

variable "startup_script" {
  type        = string
  default     = ""
  description = "Shell command to run on each VM via the CustomScript extension. Leave empty to skip. Example: 'apt-get update -y && apt-get install -y apache2'."
}

variable "enable_load_balancer" {
  type        = bool
  default     = false
  description = "Whether to deploy a Standard internal load balancer."
}

variable "lb_subnet_id" {
  type        = string
  default     = ""
  description = "Subnet ID for the load balancer frontend IP. Required when enable_load_balancer = true."
}

variable "lb_frontend_private_ip" {
  type        = string
  default     = ""
  description = "Static private IP for the load balancer frontend. Required when enable_load_balancer = true."
}
