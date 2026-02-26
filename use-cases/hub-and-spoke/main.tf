# -------------------------------------------------------
# Hub Network (Firewall + LAW + Network Watcher)
# -------------------------------------------------------

module "hub" {
  source = "../../modules/hub-network"

  location         = var.location
  product-name     = var.product-name
  tags             = var.tags
  enable_bastion   = true
  enable_flow_logs = true
}

# -------------------------------------------------------
# Spoke 01 — VMs + App Service + Private Endpoints
# -------------------------------------------------------

module "spoke_01" {
  source = "../../modules/spoke-network"

  location            = var.location
  product-name        = var.product-name
  tags                = var.tags
  spoke_name          = "spoke-01"
  spoke_address_space = "10.1.0.0/16"

  subnets = {
    "main-spk-01" = {
      cidr = "10.1.0.0/24"
    }
    "web-spk-01" = {
      cidr                       = "10.1.1.0/24"
      delegation_name            = "webapp"
      service_delegation_name    = "Microsoft.Web/serverFarms"
      service_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
    "endpoint-spk-01" = {
      cidr                                      = "10.1.2.0/24"
      private_endpoint_network_policies_enabled = true
    }
  }

  admin_ip                = var.admin_ip
  hub_vnet_id             = module.hub.hub_vnet_id
  hub_vnet_name           = module.hub.hub_vnet_name
  hub_resource_group_name = module.hub.hub_resource_group_name
  firewall_private_ip     = module.hub.firewall_private_ip
}

# -------------------------------------------------------
# Spoke 02 — VMs behind internal Load Balancer
# -------------------------------------------------------

module "spoke_02" {
  source = "../../modules/spoke-network"

  location            = var.location
  product-name        = var.product-name
  tags                = var.tags
  spoke_name          = "spoke-02"
  spoke_address_space = "10.2.0.0/16"

  subnets = {
    "main-spk-02" = {
      cidr = "10.2.0.0/24"
    }
    "front-spk-02" = {
      cidr = "10.2.1.0/24"
    }
  }

  admin_ip                = var.admin_ip
  hub_vnet_id             = module.hub.hub_vnet_id
  hub_vnet_name           = module.hub.hub_vnet_name
  hub_resource_group_name = module.hub.hub_resource_group_name
  firewall_private_ip     = module.hub.firewall_private_ip

  nsg_rules = [
    {
      name                         = "allow-http-from-spokes"
      priority                     = 1000
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      destination_port_range       = "80"
      source_address_prefixes      = ["10.1.0.0/24", "10.3.0.0/24"]
      destination_address_prefixes = ["10.2.0.0/24"]
    },
    {
      name                         = "allow-lb-health"
      priority                     = 1100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      destination_port_range       = "80"
      source_address_prefix        = "AzureLoadBalancer"
      destination_address_prefixes = ["10.2.0.0/24"]
    },
    {
      name                       = "deny-all"
      priority                   = 2000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
  ]
}

# -------------------------------------------------------
# Spoke 03 — VMs (NSG controlled)
# -------------------------------------------------------

module "spoke_03" {
  source = "../../modules/spoke-network"

  location            = var.location
  product-name        = var.product-name
  tags                = var.tags
  spoke_name          = "spoke-03"
  spoke_address_space = "10.3.0.0/16"

  subnets = {
    "main-spk-03" = {
      cidr = "10.3.0.0/24"
    }
  }

  admin_ip                = var.admin_ip
  hub_vnet_id             = module.hub.hub_vnet_id
  hub_vnet_name           = module.hub.hub_vnet_name
  hub_resource_group_name = module.hub.hub_resource_group_name
  firewall_private_ip     = module.hub.firewall_private_ip
}

# -------------------------------------------------------
# Compute — Spoke 01 (1 VM)
# -------------------------------------------------------

module "compute_spk01" {
  source = "../../modules/compute"

  location            = var.location
  product-name        = var.product-name
  tags                = var.tags
  resource_group_name = module.spoke_01.spoke_resource_group_name
  vm_subnet_id        = module.spoke_01.subnet_ids["main-spk-01"]
  vm_name_prefix      = "vmspk01"
  vm_count       = 1
  startup_script = "apt-get update -y && apt-get install -y net-tools apache2 && systemctl start apache2 && echo \"<h3>Hello from $(hostname -i)</h3>\" | tee /var/www/html/index.html"
}

# -------------------------------------------------------
# Compute — Spoke 02 (2 VMs + internal LB)
# -------------------------------------------------------

module "compute_spk02" {
  source = "../../modules/compute"

  location               = var.location
  product-name           = var.product-name
  tags                   = var.tags
  resource_group_name    = module.spoke_02.spoke_resource_group_name
  vm_subnet_id           = module.spoke_02.subnet_ids["main-spk-02"]
  vm_name_prefix         = "vmspk02"
  vm_count               = 2
  startup_script         = "apt-get update -y && apt-get install -y net-tools apache2 && systemctl start apache2 && echo \"<h3>Hello from $(hostname -i)</h3>\" | tee /var/www/html/index.html"
  enable_load_balancer   = true
  lb_subnet_id           = module.spoke_02.subnet_ids["front-spk-02"]
  lb_frontend_private_ip = "10.2.1.4"
}
