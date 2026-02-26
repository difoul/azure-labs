# -------------------------------------------------------
# Common
# -------------------------------------------------------

location     = "swedencentral"
product-name = "fbe"

tags = {
  bu  = "FBE"
  env = "dev"
}

# Your public IP in CIDR notation — required for Terraform to create the CMK key.
# Run: curl -s https://api.ipify.org && echo
# deployer_ip_rules = ["1.2.3.4/32"]

# -------------------------------------------------------
# Networking
# Hub VNet:  10.0.0.0/16
#   AzureFirewallSubnet  10.0.0.0/24
#   endpoints            10.0.1.0/24   ← ACR + KV private endpoints
#   dns-inbound          10.0.2.0/24   ← DNS Resolver inbound
#   dns-outbound         10.0.3.0/24   ← DNS Resolver outbound
#
# Spoke VNet: 10.1.0.0/16
#   container-apps       10.1.0.0/23   ← Microsoft.App/environments
# -------------------------------------------------------

spoke_address_space       = "10.1.0.0/16"
container_app_subnet_cidr = "10.1.0.0/23"
management_subnet_cidr    = "10.1.2.0/24"

# Your public IP for SSH access to the management VM.
# Run: curl -s https://api.ipify.org && echo
# admin_ip = "1.2.3.4/32"

# -------------------------------------------------------
# ACR repository (ABAC scoping)
# The pull identity is granted repository-scoped read access
# to image_repository at deploy time, so CI/CD can push and
# run images from this repo without any further IAM changes.
# -------------------------------------------------------

image_repository = "myapp/backend"

# -------------------------------------------------------
# Container App — initial deploy
#
# Workflow:
#   1. terraform apply   → deploys infrastructure + Container App
#                          running the public placeholder below.
#   2. docker push       → push your image to the ACR.
#   3. az containerapp update --name ca-fbe \
#        --resource-group rg-aca-fbe \
#        --image <acr_login_server>/myapp/backend:latest
#      → CI/CD takes over; Terraform never touches the image again.
#
# image is only used on the very first apply (lifecycle.ignore_changes
# on template means subsequent applies leave the running image alone).
# -------------------------------------------------------

image          = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
container_name = "backend"
target_port    = 80

cpu    = 0.5
memory = "1Gi"

min_replicas = 0
max_replicas = 3

env_vars = {}

# false → public ingress IP (default for dev/test).
# true  → ingress reachable only from within the VNet.
internal_load_balancer_enabled = false
