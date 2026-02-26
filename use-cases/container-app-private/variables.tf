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
  default = {}
  description = "Tags applied to all resources."
}

# -------------------------------------------------------
# Spoke networking
# -------------------------------------------------------

variable "deployer_ip_rules" {
  type        = list(string)
  default     = []
  description = "Your public IP(s) in CIDR notation (e.g. [\"1.2.3.4/32\"]) allowed to reach the Key Vault during terraform apply."
}

variable "spoke_address_space" {
  type        = string
  default     = "10.1.0.0/16"
  description = "CIDR address space for the Container Apps spoke VNet."
}

variable "container_app_subnet_cidr" {
  type        = string
  default     = "10.1.0.0/23"
  description = "CIDR for the container-apps subnet within the spoke. Minimum /27; /23 recommended for workload-profiles environments."
}

variable "management_subnet_cidr" {
  type        = string
  default     = "10.1.2.0/24"
  description = "CIDR for the management subnet hosting the jumpbox VM."
}

variable "admin_ip" {
  type        = string
  default     = ""
  description = "Your public IP in CIDR notation (e.g. '1.2.3.4/32'). Creates an NSG inbound allow-all rule for SSH access to the management VM."
}

# -------------------------------------------------------
# Container App workload
# -------------------------------------------------------

variable "image_repository" {
  type        = string
  default     = "my-repo"
  description = "Repository path within the ACR used for ABAC scoping (e.g. 'myapp/backend'). The pull identity is granted read access to this repository only."
}

variable "image" {
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
  description = "Full image reference for the initial deploy. Defaults to a public placeholder; after first apply the template is ignored by Terraform and image updates are handled by CI/CD."
}

variable "container_name" {
  type        = string
  default     = "app"
  description = "Name of the container inside the Container App."
}

variable "cpu" {
  type    = number
  default = 0.5
}

variable "memory" {
  type    = string
  default = "1Gi"
}

variable "min_replicas" {
  type    = number
  default = 0
}

variable "max_replicas" {
  type    = number
  default = 3
}

variable "target_port" {
  type    = number
  default = 80
}

variable "env_vars" {
  type        = map(string)
  default     = {}
  description = "Environment variables injected into the container."
}

variable "internal_load_balancer_enabled" {
  type        = bool
  default     = false
  description = "When true, the Container App Environment uses an internal (VNet-only) load balancer."
}
