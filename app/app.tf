# Create network interface
resource azurerm_network_interface app01-nic {
  name                = "${var.prefix}-app01-nic"
  location            = var.resourceGroup.location
  resource_group_name = var.resourceGroup.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.missionownermgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.app01ext
    primary                       = true
  }

  tags = var.tags
}

# Connect the security group to the network interface
resource azurerm_network_interface_security_group_association appnsg {
  network_interface_id      = azurerm_network_interface.app01-nic.id
  network_security_group_id = var.securityGroup.id
}

# Create virtual machine
resource azurerm_linux_virtual_machine app01 {
  name                  = "${var.prefix}-app01"
  location              = var.resourceGroup.location
  resource_group_name   = var.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.app01-nic.id]
  size                  = var.instanceType

  admin_username                  = var.adminUserName
  admin_password                  = var.adminPassword
  disable_password_authentication = false
  computer_name                   = "app01"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  custom_data = base64encode("apt-get update -y; sudo apt-get install -y nginx;")

  admin_ssh_key {
    username   = var.adminUserName
    public_key = file("~/.ssh/id_rsa.pub")
  }

  tags = var.tags
}

resource azurerm_virtual_machine_extension app01-run-startup {
  name                 = "app01-run-startup-cmd"
  depends_on           = [azurerm_linux_virtual_machine.app01]
  virtual_machine_id   = azurerm_linux_virtual_machine.app01.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${base64encode(file("./app/app.sh"))}"
    }
    SETTINGS

  tags = var.tags
}