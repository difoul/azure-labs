resource "azurerm_network_interface" "vm-spk-02-nic-01" {
  name                = "vm-spk-02-nic-01-${var.product-name}"
  location            = azurerm_resource_group.vms-rg.location
  resource_group_name = azurerm_resource_group.vms-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main_subnet-spoke-02.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm01-spk02" {
  name                            = "vm01spk02${var.product-name}" #Not allowed `\/"[]:|<>+=;,?*@&~!#$%^()_{}'`
  location                        = azurerm_resource_group.vms-rg.location
  resource_group_name             = azurerm_resource_group.vms-rg.name
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = var.pwd # random_password.pwd.result
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.vm-spk-02-nic-01.id,
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

resource "azurerm_virtual_machine_extension" "start-apache-server-01" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm01-spk02.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "script": "c3VkbyBhcHQgdXBkYXRlIC15CnN1ZG8gYXB0IGluc3RhbGwgbmV0LXRvb2xzIC15CnN1ZG8gYXB0IGluc3RhbGwgYXBhY2hlMiAteQpzdWRvIHN5c3RlbWN0bCBzdGFydCBhcGFjaGUyCnN1ZG8gY2hvd24gLVIgJFVTRVI6JFVTRVIgL3Zhci93d3cKc3VkbyBlY2hvICI8aDM+SGVsbG8gZnJvbSB2aXJ0dWFsIG1hY2hpbmUgOiA8L2gzPiA8aDI+PGk+JChob3N0bmFtZSAtaSk8L2k+PC9oMj4iID4gL3Zhci93d3cvaHRtbC9pbmRleC5odG1sCg=="
 }
SETTINGS


  tags = var.tags
}

resource "azurerm_network_interface" "vm-spk-02-nic-02" {
  name                = "vm-spk-02-nic-02-${var.product-name}"
  location            = azurerm_resource_group.vms-rg.location
  resource_group_name = azurerm_resource_group.vms-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main_subnet-spoke-02.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm02-spk02" {
  name                            = "vm02spk02${var.product-name}" #Not allowed `\/"[]:|<>+=;,?*@&~!#$%^()_{}'`
  location                        = azurerm_resource_group.vms-rg.location
  resource_group_name             = azurerm_resource_group.vms-rg.name
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = var.pwd
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.vm-spk-02-nic-02.id,
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

resource "azurerm_virtual_machine_extension" "start-apache-server-02" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm02-spk02.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "script": "c3VkbyBhcHQgdXBkYXRlIC15CnN1ZG8gYXB0IGluc3RhbGwgbmV0LXRvb2xzIC15CnN1ZG8gYXB0IGluc3RhbGwgYXBhY2hlMiAteQpzdWRvIHN5c3RlbWN0bCBzdGFydCBhcGFjaGUyCnN1ZG8gY2hvd24gLVIgJFVTRVI6JFVTRVIgL3Zhci93d3cKc3VkbyBlY2hvICI8aDM+SGVsbG8gZnJvbSB2aXJ0dWFsIG1hY2hpbmUgOiA8L2gzPiA8aDI+PGk+JChob3N0bmFtZSAtaSk8L2k+PC9oMj4iID4gL3Zhci93d3cvaHRtbC9pbmRleC5odG1sCg=="
 }
SETTINGS


  tags = var.tags
}
