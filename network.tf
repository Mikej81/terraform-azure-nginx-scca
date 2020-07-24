# Create virtual network
resource azurerm_virtual_network main {
  name                = "${var.projectPrefix}-network"
  address_space       = [var.cidr]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = var.tags
}

# Create subnets
resource azurerm_subnet missionownerext {
  name                 = "missionowner_ext"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [var.subnets["data_ext"]]
}

resource azurerm_subnet missionownerint {
  name                 = "missionowner_int"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [var.subnets["data_int"]]
}

resource azurerm_subnet missionownermgmt {
  name                 = "missionowner_mgmt"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [var.subnets["management"]]
}

# Obtain Gateway IP for each Subnet
locals {
  depends_on = [azurerm_subnet.missionownermgmt, azurerm_subnet.missionownerint, azurerm_subnet.missionownerext]
  mgmt_gw    = "${cidrhost(azurerm_subnet.missionownermgmt.address_prefix, 1)}"
  ext_gw     = "${cidrhost(azurerm_subnet.missionownerext.address_prefix, 1)}"
  int_gw     = "${cidrhost(azurerm_subnet.missionownerint.address_prefix, 1)}"
}

# Get my current Public IP for NSG
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Create Network Security Group and rule
resource azurerm_network_security_group main {
  name                = "${var.projectPrefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "23"
    source_address_prefix      = chomp(data.http.myip.body)
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "SSH2"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = chomp(data.http.myip.body)
    destination_address_prefix = "*"
  }

  tags = var.tags
}