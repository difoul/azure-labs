# -------------------------------------------------------
# Minimal Hub Network
# Provides the hub VNet and endpoints subnet for private endpoints
# -------------------------------------------------------

module "hub" {
  source = "../../modules/hub-network"

  location     = var.location
  product-name = var.product-name
  tags         = var.tags
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
# ACR + Private Endpoint + DNS Zone
# -------------------------------------------------------

module "acr" {
  source = "../../modules/acr"

  location                  = var.location
  product-name              = var.product-name
  tags                      = var.tags
  hub_vnet_id               = module.hub.hub_vnet_id
  endpoint_subnet_id        = module.hub.endpoint_subnet_id
  key_vault_id              = module.key_vault.key_vault_id
  key_vault_key_id          = module.key_vault.key_vault_key_id
  enable_abac               = var.enable_abac
  repositories              = var.repositories
  geo_replication_locations = var.geo_replication_locations
}
