resource "azurerm_lb" "vm02-lb" {
  location            = azurerm_resource_group.vms-rg.location
  name                = "vm02-lb"
  resource_group_name = azurerm_resource_group.vms-rg.name
  frontend_ip_configuration {
    name                          = "frontend-private-ip"
    subnet_id                     = azurerm_subnet.front_subnet-spoke-02.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.2.1.4"
  }
}

# Create a Backend Address Pool for the Load Balancer
resource "azurerm_lb_backend_address_pool" "address-pool" {
  loadbalancer_id = azurerm_lb.vm02-lb.id
  name            = "address-pool"
}

# Create a Load Balancer Probe to check the health of the
# Virtual Machines in the Backend Pool
resource "azurerm_lb_probe" "check-health-probe" {
  loadbalancer_id = azurerm_lb.vm02-lb.id
  name            = "check-health-probe"
  port            = 80
}

# Create a Load Balancer Rule to define how traffic will be
# distributed to the Virtual Machines in the Backend Pool
resource "azurerm_lb_rule" "lb-rule-80" {
  loadbalancer_id                = azurerm_lb.vm02-lb.id
  name                           = "lb-rule-80"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "frontend-private-ip"
  probe_id                       = azurerm_lb_probe.check-health-probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.address-pool.id]
}

# resource "azurerm_lb_backend_address_pool_address" "backend-pool-address" {
#   name = "vms"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.address-pool.id
#
# }

resource "azurerm_network_interface_backend_address_pool_association" "vm02-nic" {
  network_interface_id    = azurerm_network_interface.vm-spk-02-nic-02.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.address-pool.id
  ip_configuration_name   = azurerm_network_interface.vm-spk-02-nic-02.ip_configuration[0].name
}