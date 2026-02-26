# -------------------------------------------------------
# Hub Network
# Provides hub VNet, Firewall, Log Analytics, private
# endpoints subnet, and the Private DNS Resolver.
# All privatelink DNS zones link only to the hub VNet.
# -------------------------------------------------------

module "hub" {
  source = "../../modules/hub-network"

  location     = var.location
  product-name = var.product-name
  tags         = var.tags

  # Creates DNS resolver subnets + resolver + inbound/outbound endpoints.
  # The inbound IP is passed to the spoke as its custom DNS server so that
  # privatelink zones (linked only to the hub VNet) resolve correctly.
  enable_dns_resolver = true
}

# -------------------------------------------------------
# Managed Identity — ACR repository pull
#
# Created at the use-case level so it can be referenced by
# both the ACR module (ABAC repository assignment) and the
# container-app module (image pull), without creating a
# circular module dependency.
# -------------------------------------------------------

resource "azurerm_resource_group" "identities" {
  name     = "rg-id-${var.product-name}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_user_assigned_identity" "aca_pull" {
  name                = "id-aca-pull-${var.product-name}"
  location            = azurerm_resource_group.identities.location
  resource_group_name = azurerm_resource_group.identities.name
  tags                = var.tags
}

# -------------------------------------------------------
# Key Vault + CMK Key
# -------------------------------------------------------

module "key_vault" {
  source = "../../modules/key-vault"

  location           = var.location
  product-name       = var.product-name
  tags               = var.tags
  hub_vnet_id        = module.hub.hub_vnet_id
  endpoint_subnet_id = module.hub.endpoint_subnet_id
  deployer_ip_rules  = var.deployer_ip_rules
}

# -------------------------------------------------------
# ACR — private endpoint in hub, CMK encryption, ABAC enabled
#
# ABAC restricts the pull identity to var.image_repository only.
# The DNS zone links to the hub VNet; spoke resolution flows
# via the hub Private DNS Resolver.
# -------------------------------------------------------

module "acr" {
  source = "../../modules/acr"

  location           = var.location
  product-name       = var.product-name
  tags               = var.tags
  hub_vnet_id        = module.hub.hub_vnet_id
  endpoint_subnet_id = module.hub.endpoint_subnet_id
  key_vault_id       = module.key_vault.key_vault_id
  key_vault_key_id   = module.key_vault.key_vault_key_id

  enable_abac = true

  repositories = {
    (var.image_repository) = {
      pull_principal_ids = [azurerm_user_assigned_identity.aca_pull.principal_id]
    }
  }
}

# -------------------------------------------------------
# Container Apps Spoke
# Dedicated spoke VNet peered to the hub, hosting the
# Container App Environment in a delegated subnet.
#
# Subnet layout:
#   container-apps  10.1.0.0/23   Microsoft.App/environments delegation
#
# custom_dns_servers points to the hub DNS Resolver inbound
# endpoint so the spoke resolves privatelink.azurecr.io
# via the hub-linked private DNS zone.
# -------------------------------------------------------

module "spoke" {
  source = "../../modules/spoke-network"

  location     = var.location
  product-name = var.product-name
  tags         = var.tags

  spoke_name          = "spoke-aca"
  spoke_address_space = var.spoke_address_space

  hub_vnet_id             = module.hub.hub_vnet_id
  hub_vnet_name           = module.hub.hub_vnet_name
  hub_resource_group_name = module.hub.hub_resource_group_name
  firewall_private_ip     = module.hub.firewall_private_ip

  admin_ip           = var.admin_ip
  custom_dns_servers = [module.hub.dns_resolver_inbound_ip]

  subnets = {
    container-apps = {
      cidr                    = var.container_app_subnet_cidr
      delegation_name         = "Microsoft.App.environments"
      service_delegation_name = "Microsoft.App/environments"
      service_delegation_actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
    management = {
      cidr = var.management_subnet_cidr
    }
  }
}

# -------------------------------------------------------
# Management VM
# Cheapest reliable SKU (Standard_B1s, 1 vCPU / 1 GiB) with
# Azure CLI pre-installed. Use via Bastion or SSH from admin_ip.
# -------------------------------------------------------

module "management_vm" {
  source = "../../modules/compute"

  location            = var.location
  product-name        = var.product-name
  tags                = var.tags
  resource_group_name = module.spoke.spoke_resource_group_name
  vm_subnet_id        = module.spoke.subnet_ids["management"]
  vm_name_prefix      = "vm-mgmt"
  vm_size             = "Standard_B1s"
  vm_count            = 1

  startup_script = "apt-get update -y && apt-get install -y curl git docker.io && curl -sL https://aka.ms/InstallAzureCLIDeb | bash"
}

# -------------------------------------------------------
# Container App
# VNet-injected into the spoke container-apps subnet.
# Uses the ABAC-scoped pull identity — no broad AcrPull,
# no admin credentials, access limited to var.image_repository.
# -------------------------------------------------------

module "container_app" {
  source = "../../modules/container-app"

  location     = var.location
  product-name = var.product-name
  tags         = var.tags

  subnet_id                      = module.spoke.subnet_ids["container-apps"]
  pull_identity_id               = azurerm_user_assigned_identity.aca_pull.id
  acr_login_server               = module.acr.acr_login_server
  log_analytics_workspace_id     = module.hub.log_analytics_workspace_id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled

  image          = var.image
  container_name = var.container_name
  cpu            = var.cpu
  memory         = var.memory
  min_replicas   = var.min_replicas
  max_replicas   = var.max_replicas
  target_port    = var.target_port
  env_vars       = var.env_vars
}
