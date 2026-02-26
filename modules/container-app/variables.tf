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

# -------------------------------------------------------
# Networking
# -------------------------------------------------------

variable "subnet_id" {
  type        = string
  description = "Resource ID of the dedicated Container Apps subnet (delegated to Microsoft.App/environments) in the hub VNet."
}

# -------------------------------------------------------
# ACR (registry pull)
# -------------------------------------------------------

variable "pull_identity_id" {
  type        = string
  description = "Resource ID of the externally-created user-assigned managed identity that has ABAC pull permissions on the ACR. Attached to the Container App for passwordless image pull."
}

variable "acr_login_server" {
  type        = string
  description = "Login server hostname of the ACR (e.g. acrfbe.azurecr.io). Used in the registry block for managed-identity authentication. The pull credential is in place from first deploy so CI/CD can switch to an ACR image at any time."
}

# -------------------------------------------------------
# Monitoring
# -------------------------------------------------------

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics Workspace for Container App Environment diagnostics."
}

# -------------------------------------------------------
# Container App Environment
# -------------------------------------------------------

variable "internal_load_balancer_enabled" {
  type        = bool
  default     = false
  description = "When true, the environment uses an internal (private) load balancer — ingress is reachable only from within the VNet. When false, ingress has a public IP."
}

variable "zone_redundancy_enabled" {
  type        = bool
  default     = false
  description = "Enable zone redundancy on the Container App Environment."
}

# -------------------------------------------------------
# Container App — workload
# -------------------------------------------------------

variable "image" {
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
  description = <<-EOT
    Full image reference used on the first terraform apply only.
    Defaults to a public Microsoft placeholder so the deploy succeeds even when
    the ACR is still empty. After the first apply, lifecycle.ignore_changes on
    the template block means Terraform will never overwrite this value — image
    updates are owned by CI/CD (az containerapp update --image ...).
    Once you are ready to switch to your ACR image, set this to
    "<acr_login_server>/<repository>:<tag>" and taint the resource to force
    a one-time re-apply, or simply let CI/CD handle it.
  EOT
}

variable "container_name" {
  type        = string
  default     = "app"
  description = "Name of the container inside the Container App."
}

variable "cpu" {
  type        = number
  default     = 0.5
  description = "vCPU allocated to the container (e.g. 0.25, 0.5, 1.0, 2.0)."
}

variable "memory" {
  type        = string
  default     = "1Gi"
  description = "Memory allocated to the container (e.g. '0.5Gi', '1Gi', '2Gi'). Must be compatible with the cpu value."
}

variable "min_replicas" {
  type        = number
  default     = 0
  description = "Minimum number of replicas (0 allows scale-to-zero)."
}

variable "max_replicas" {
  type        = number
  default     = 3
  description = "Maximum number of replicas."
}

variable "target_port" {
  type        = number
  default     = 80
  description = "Port the container listens on. Used for ingress routing."
}

variable "env_vars" {
  type        = map(string)
  default     = {}
  description = "Environment variables injected into the container as plain-text key/value pairs."
}
