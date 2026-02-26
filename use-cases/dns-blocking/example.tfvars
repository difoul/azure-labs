location     = "swedencentral"
product-name = "fbe"

tags = {
  bu  = "FBE"
  env = "dev"
}

# Domains to allow (with trailing dot); everything else is blocked
allowed_domains = ["difoul.io."]

# Private DNS zones to create and link to hub VNet
allowed_private_zones = ["difoul.io"]
