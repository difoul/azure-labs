# -------------------------------------------------------
# Hub Network with DNS resolver subnets enabled
# -------------------------------------------------------

module "hub" {
  source = "../../modules/hub-network"

  location                    = var.location
  product-name                = var.product-name
  tags                        = var.tags
  enable_dns_resolver_subnets = true
}

# -------------------------------------------------------
# DNS Security — resolver + allow/block policy
# -------------------------------------------------------

module "dns_security" {
  source = "../../modules/dns-security"

  location              = var.location
  product-name          = var.product-name
  tags                  = var.tags
  hub_vnet_id           = module.hub.hub_vnet_id
  inbound_subnet_id     = module.hub.inbound_dns_subnet_id
  outbound_subnet_id    = module.hub.outbound_dns_subnet_id
  allowed_domains       = var.allowed_domains
  allowed_private_zones = var.allowed_private_zones
}
