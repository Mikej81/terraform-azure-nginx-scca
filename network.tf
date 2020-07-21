# Create virtual network
resource azurerm_virtual_network main {
  name                = "${var.projectPrefix}-network"
  address_space       = [var.cidr]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = var.tags
}

# Create public IPs
resource azurerm_public_ip lbpip {
  name                = "${var.projectPrefix}-lb-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  domain_name_label   = "${var.projectPrefix}lbpip"
  #sku                 = "Standard"

  tags = var.tags
}
output http_url { value = "http://${azurerm_public_ip.lbpip.ip_address}" }
output ssh_url { value = "ssh://${var.adminUserName}@${azurerm_public_ip.lbpip.ip_address}" }

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

  tags = var.tags
}

# Create Azure LB
resource azurerm_lb lb {
  name                = "${var.projectPrefix}lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  #sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lbpip.id
  }
}

resource azurerm_lb_backend_address_pool backend_pool {
  name                = "BackendPool1"
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
}

resource azurerm_lb_backend_address_pool backend_mgmt_pool {
  name                = "BackendMgmtPool1"
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
}

resource azurerm_lb_probe http_probe {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "http_probe"
  protocol            = "Http"
  port                = 80
  request_path        = "/health"
  interval_in_seconds = 5
  number_of_probes    = 2
}

# resource azurerm_lb_probe https_probe {
#   resource_group_name = azurerm_resource_group.main.name
#   loadbalancer_id     = azurerm_lb.lb.id
#   name                = "https_probe"
#   protocol            = "Https"
#   port                = 443
#   request_path        = "/health"
#   interval_in_seconds = 5
#   number_of_probes    = 2
# }

resource azurerm_lb_probe tcp_probe {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "tcp_probe"
  protocol            = "Tcp"
  port                = 23
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource azurerm_lb_rule http_rule {
  name                           = "HTTP_Rule"
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.http_probe.id
  depends_on                     = [azurerm_lb_probe.http_probe]
}

resource azurerm_lb_rule ssh_rule {
  name                           = "SSH_Rule"
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "tcp"
  frontend_port                  = 23
  backend_port                   = 23
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.tcp_probe.id
  depends_on                     = [azurerm_lb_probe.tcp_probe]
}

resource azurerm_lb_rule https_rule {
  name                           = "HTTPS_Rule"
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.http_probe.id
  depends_on                     = [azurerm_lb_probe.http_probe]
}

resource azurerm_lb_rule management_rule {
  name                           = "management_Rule"
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "tcp"
  frontend_port                  = 4443
  backend_port                   = 4443
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_mgmt_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.tcp_probe.id
  depends_on                     = [azurerm_lb_probe.tcp_probe]
}