# -------------------------------------------------------
# Random password for VM admin
# -------------------------------------------------------

resource "random_password" "vm" {
  length  = 16
  special = true
  lower   = true
  upper   = true
  numeric = true
}

# -------------------------------------------------------
# Network Interfaces
# -------------------------------------------------------

resource "azurerm_network_interface" "vm" {
  count               = var.vm_count
  name                = "${var.vm_name_prefix}-nic-${count.index + 1}-${var.product-name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# -------------------------------------------------------
# Linux Virtual Machines
# -------------------------------------------------------

resource "azurerm_linux_virtual_machine" "vm" {
  count                           = var.vm_count
  name                            = "${var.vm_name_prefix}${count.index + 1}${var.product-name}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = random_password.vm.result
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.vm[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = var.tags
}

# Generic startup script via CustomScript extension
resource "azurerm_virtual_machine_extension" "startup" {
  count                = var.startup_script != "" ? var.vm_count : 0
  name                 = "startup-script-${count.index + 1}"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = jsonencode({
    script = base64encode(var.startup_script)
  })

  tags = var.tags
}

# -------------------------------------------------------
# Internal Load Balancer (optional)
# -------------------------------------------------------

resource "azurerm_lb" "this" {
  count               = var.enable_load_balancer ? 1 : 0
  location            = var.location
  name                = "${var.vm_name_prefix}-lb-${var.product-name}"
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "frontend-private-ip"
    subnet_id                     = var.lb_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.lb_frontend_private_ip
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "this" {
  count           = var.enable_load_balancer ? 1 : 0
  loadbalancer_id = azurerm_lb.this[0].id
  name            = "backend-pool"
}

resource "azurerm_lb_probe" "http" {
  count           = var.enable_load_balancer ? 1 : 0
  loadbalancer_id = azurerm_lb.this[0].id
  name            = "http-health-probe"
  port            = 80
}

resource "azurerm_lb_rule" "http" {
  count                          = var.enable_load_balancer ? 1 : 0
  loadbalancer_id                = azurerm_lb.this[0].id
  name                           = "lb-rule-http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  disable_outbound_snat          = true
  frontend_ip_configuration_name = "frontend-private-ip"
  probe_id                       = azurerm_lb_probe.http[0].id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this[0].id]
}

resource "azurerm_network_interface_backend_address_pool_association" "vm" {
  count                   = var.enable_load_balancer ? var.vm_count : 0
  network_interface_id    = azurerm_network_interface.vm[count.index].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.this[0].id
  ip_configuration_name   = azurerm_network_interface.vm[count.index].ip_configuration[0].name
}
