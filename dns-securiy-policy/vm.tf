resource "azurerm_network_interface" "vm-spk-01-nic-01" {
  name                = "vm-spk-01-nic-01-${var.product-name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main_subnet-spoke-01.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm01-spk01" {
  name                            = "vm01spk01${var.product-name}" #Not allowed `\/"[]:|<>+=;,?*@&~!#$%^()_{}'`
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = var.pwd # random_password.pwd.result
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.vm-spk-01-nic-01.id,
  ]


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
