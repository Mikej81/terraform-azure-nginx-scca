resource random_id public_ip {
  byte_length = 4
}

# Create public IPs
resource azurerm_public_ip proxy01pip {
  name                = "${var.projectPrefix}-proxy01-pip"
  location                      = var.resourceGroup.location
  resource_group_name           = var.resourceGroup.name
  allocation_method   = "Static"
  domain_name_label   = "mo-1${lower(random_id.public_ip.hex)}"
  #sku                 = "Standard"

  tags = var.tags
}

resource azurerm_public_ip proxy02pip {
  name                = "${var.projectPrefix}-proxy02-pip"
  location                      = var.resourceGroup.location
  resource_group_name           = var.resourceGroup.name
  allocation_method   = "Static"
  domain_name_label   = "mo-2${lower(random_id.public_ip.hex)}"
  #sku                 = "Standard"

  tags = var.tags
}


output proxy1_url { value = "https://${azurerm_public_ip.proxy01pip.fqdn}" }
output proxy2_url { value = "https://${azurerm_public_ip.proxy02pip.fqdn}" }

output app_ssh_url { value = "ssh ${var.adminUserName}@${azurerm_public_ip.proxy01pip.ip_address} -p 23" }

# Create the management network interface card
resource azurerm_network_interface proxy01-mgmt-nic {
  name                          = "${var.prefix}-proxy01-mgmt-nic"
  location                      = var.resourceGroup.location
  resource_group_name           = var.resourceGroup.name
  enable_accelerated_networking = false
  enable_ip_forwarding          = false

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.missionownermgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.proxy01mgmt
    primary                       = true
  }

  tags = var.tags
}

resource azurerm_network_interface proxy02-mgmt-nic {
  name                          = "${var.prefix}-proxy02-mgmt-nic"
  location                      = var.resourceGroup.location
  resource_group_name           = var.resourceGroup.name
  enable_accelerated_networking = false
  enable_ip_forwarding          = false

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.missionownermgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.proxy02mgmt
    primary                       = true
  }

  tags = var.tags
}

resource azurerm_network_interface_security_group_association proxy01-mgmt-nsg {
  network_interface_id      = azurerm_network_interface.proxy01-mgmt-nic.id
  network_security_group_id = var.securityGroup.id
}

resource azurerm_network_interface_security_group_association proxy02-mgmt-nsg {
  network_interface_id      = azurerm_network_interface.proxy02-mgmt-nic.id
  network_security_group_id = var.securityGroup.id
}

# Create the external network interface card
resource azurerm_network_interface proxy01-ext-nic {
  name                          = "${var.prefix}-proxy01-ext-nic"
  location                      = var.resourceGroup.location
  resource_group_name           = var.resourceGroup.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.missionownerext.id
    public_ip_address_id          = azurerm_public_ip.proxy01pip.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.proxy01ext
    primary                       = true
  }

  tags = var.tags
}

resource azurerm_network_interface proxy02-ext-nic {
  name                          = "${var.prefix}-proxy02-ext-nic"
  location                      = var.resourceGroup.location
  resource_group_name           = var.resourceGroup.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.missionownerext.id
    public_ip_address_id          = azurerm_public_ip.proxy02pip.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.proxy02ext
    primary                       = true
  }

  tags = var.tags
}

resource azurerm_network_interface_security_group_association proxy01-ext-nsg {
  network_interface_id      = azurerm_network_interface.proxy01-ext-nic.id
  network_security_group_id = var.securityGroup.id
}

resource azurerm_network_interface_security_group_association proxy02-ext-nsg {
  network_interface_id      = azurerm_network_interface.proxy02-ext-nic.id
  network_security_group_id = var.securityGroup.id
}

# Create the internal interface card
resource azurerm_network_interface proxy01-int-nic {
  name                          = "${var.prefix}-proxy01-int-nic"
  location                      = var.resourceGroup.location
  resource_group_name           = var.resourceGroup.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.missionownerint.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.proxy01int
    primary                       = true
  }

  tags = var.tags
}

resource azurerm_network_interface proxy02-int-nic {
  name                          = "${var.prefix}-proxy02-int-nic"
  location                      = var.resourceGroup.location
  resource_group_name           = var.resourceGroup.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.missionownerint.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.proxy02int
    primary                       = true
  }

  tags = var.tags
}

resource azurerm_network_interface_security_group_association proxy01-int-nsg {
  network_interface_id      = azurerm_network_interface.proxy01-int-nic.id
  network_security_group_id = var.securityGroup.id
}

resource azurerm_network_interface_security_group_association proxy02-int-nsg {
  network_interface_id      = azurerm_network_interface.proxy02-int-nic.id
  network_security_group_id = var.securityGroup.id
}

# set up proxy config

data template_file nginx_config {
  template = "${file("./proxy/nginx.conf")}"
  vars = {
    app_address = var.app01ext
  }
}

data template_file proxy01_config {
  template = "${file("./proxy/proxy.conf")}"
  vars = {
    listener_ip = var.proxy01ext
    pip_dns     = azurerm_public_ip.proxy01pip.fqdn
    app_address = var.app01ext
  }
}

data template_file proxy02_config {
  template = "${file("./proxy/proxy.conf")}"
  vars = {
    listener_ip = var.proxy02ext
    pip_dns     = azurerm_public_ip.proxy02pip.fqdn
    app_address = var.app01ext
  }
}

data template_file startup_script01 {
  template = "${file("./proxy/proxy.sh")}"
  vars = {
    active_device = "proxy01"
    proxy01_add   = var.proxy01ext
    proxy02_add   = var.proxy02ext
    #admin_user    = var.adminUserName
    adminUserName = var.adminUserName
    adminPassword = var.adminPassword
    nginx_config  = base64encode(data.template_file.nginx_config.rendered)
    proxy_config  = base64encode(data.template_file.proxy01_config.rendered)
    modsec_config = base64encode(file("./proxy/modsec.conf"))
    fqdn          = azurerm_public_ip.proxy01pip.fqdn
    owner         = var.owner
  }
}

data template_file startup_script02 {
  template = "${file("./proxy/proxy.sh")}"
  vars = {
    active_device = "proxy02"
    proxy01_add   = var.proxy01ext
    proxy02_add   = var.proxy02ext
    #admin_user    = var.adminUserName
    adminUserName = var.adminUserName
    adminPassword = var.adminPassword
    nginx_config  = base64encode(data.template_file.nginx_config.rendered)
    proxy_config  = base64encode(data.template_file.proxy02_config.rendered)
    modsec_config = base64encode(file("./proxy/modsec.conf"))
    fqdn          = azurerm_public_ip.proxy02pip.fqdn
    owner         = var.owner
  }
}

# Debug Template Outputs
resource local_file nginx_config_file {
  content  = data.template_file.nginx_config.rendered
  filename = "${path.module}/nginx_render.conf"
}

resource local_file proxy01_config_file {
  content  = data.template_file.proxy01_config.rendered
  filename = "${path.module}/proxy01.conf"
}

resource local_file startup_script_file {
  content  = data.template_file.startup_script01.rendered
  filename = "${path.module}/startup_script01.sh"
}

resource local_file startup_script_file02 {
  content  = data.template_file.startup_script02.rendered
  filename = "${path.module}/startup_script01.sh"
}

# Create virtual machine
resource azurerm_linux_virtual_machine proxy01 {
  name                = "${var.prefix}-proxy01"
  location            = var.resourceGroup.location
  resource_group_name = var.resourceGroup.name

  availability_set_id = var.availabilitySet.id

  network_interface_ids = [azurerm_network_interface.proxy01-ext-nic.id, azurerm_network_interface.proxy01-int-nic.id, azurerm_network_interface.proxy01-mgmt-nic.id]
  size                  = var.instanceType

  admin_username                  = var.adminUserName
  admin_password                  = var.adminPassword
  computer_name                   = "${var.prefix}proxy01"
  disable_password_authentication = false

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
  admin_ssh_key {
    username   = var.adminUserName
    public_key = file("~/.ssh/id_rsa.pub")
  }

  tags = var.tags
}

resource azurerm_virtual_machine_extension proxy01-run-startup {
  name                 = "proxy01-run-startup-cmd"
  depends_on           = [azurerm_linux_virtual_machine.proxy01]
  virtual_machine_id   = azurerm_linux_virtual_machine.proxy01.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${base64encode(data.template_file.startup_script01.rendered)}"
    }
    SETTINGS

  tags = var.tags
}

resource azurerm_linux_virtual_machine proxy02 {
  name                = "${var.prefix}-proxy02"
  location            = var.resourceGroup.location
  resource_group_name = var.resourceGroup.name
  availability_set_id = var.availabilitySet.id

  network_interface_ids = [azurerm_network_interface.proxy02-ext-nic.id, azurerm_network_interface.proxy02-int-nic.id, azurerm_network_interface.proxy02-mgmt-nic.id]
  size                  = var.instanceType

  admin_username = var.adminUserName
  admin_password = var.adminPassword
  computer_name  = "${var.prefix}proxy02"

  disable_password_authentication = false

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
  admin_ssh_key {
    username   = var.adminUserName
    public_key = file("~/.ssh/id_rsa.pub")
  }

  tags = var.tags
}

resource azurerm_virtual_machine_extension proxy02-run-startup {
  name                 = "proxy02-run-startup-cmd"
  depends_on           = [azurerm_linux_virtual_machine.proxy02]
  virtual_machine_id   = azurerm_linux_virtual_machine.proxy02.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${base64encode(data.template_file.startup_script02.rendered)}"
    }
    SETTINGS

  tags = var.tags
}
