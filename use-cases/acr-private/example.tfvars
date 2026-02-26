location     = "swedencentral"
product-name = "fbe"

tags = {
  bu  = "FBE"
  env = "dev"
}

# Your public IP in CIDR notation — required for Terraform to create the CMK key.
# Run: curl -s https://api.ipify.org && echo
# deployer_ip_rules = ["1.2.3.4/32"]

# Enable ABAC and assign repository-scoped roles:
# enable_abac = true
#
# repositories = {
#   "myapp/backend" = {
#     pull_principal_ids = ["<object-id-of-ci-runner>"]
#     push_principal_ids = ["<object-id-of-dev-team-sp>"]
#   }
#   "myapp/frontend" = {
#     pull_principal_ids = ["<object-id-of-aks-kubelet>"]
#     push_principal_ids = ["<object-id-of-dev-team-sp>"]
#   }
# }

# Optionally enable geo-replication:
# geo_replication_locations = [
#   {
#     location                  = "northeurope"
#     zone_redundancy_enabled   = true
#     regional_endpoint_enabled = true
#   }
# ]
