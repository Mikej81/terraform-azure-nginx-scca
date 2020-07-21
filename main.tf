# Create (and display) an SSH key
resource tls_private_key ssh {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# output "tls_private_key" { value = "${tls_private_key.example_ssh.private_key_pem}" }

# deploy nginx app server
module nginx_app {
  source        = "./app"
  prefix        = var.projectPrefix
  resourceGroup = azurerm_resource_group.main
  location      = var.location
  #sshPublicKey = var.adminPubKey
  ssh_key          = chomp(tls_private_key.ssh.public_key_openssh)
  region           = var.region
  missionownermgmt = azurerm_subnet.missionownerint
  securityGroup    = azurerm_network_security_group.main
  app01ext         = var.app01ext
  adminUserName    = var.adminUserName
  adminPassword    = var.adminPassword
  projectPrefix    = var.projectPrefix
  #availabilitySet = azurerm_availability_set.avset
  instanceType = var.instanceType["application"]
  tags         = var.tags
}

# deploy nginx proxyies
module nginx_proxy {
  source        = "./proxy"
  prefix        = var.projectPrefix
  resourceGroup = azurerm_resource_group.main
  #sshPublicKey = var.adminPubKey
  ssh_key          = chomp(tls_private_key.ssh.public_key_openssh)
  region           = var.region
  location      = var.location
  missionownermgmt = azurerm_subnet.missionownermgmt
  missionownerext  = azurerm_subnet.missionownerext
  missionownerint  = azurerm_subnet.missionownerint
  securityGroup    = azurerm_network_security_group.main
  proxy01int       = var.proxy01int
  proxy01ext       = var.proxy01ext
  proxy01mgmt      = var.proxy01mgmt
  proxy02int       = var.proxy02int
  proxy02ext       = var.proxy02ext
  proxy02mgmt      = var.proxy02mgmt
  app01ext         = var.app01ext
  adminUserName    = var.adminUserName
  adminPassword    = var.adminPassword
  projectPrefix    = var.projectPrefix
  active_device    = var.active_device
  backendPool      = azurerm_lb_backend_address_pool.backend_pool
  managementPool   = azurerm_lb_backend_address_pool.backend_mgmt_pool
  #app_address = var.app01ext
  pip_dns         = "${azurerm_public_ip.lbpip.domain_name_label}.${var.region_domain}"
  availabilitySet = azurerm_availability_set.avset
  storage_account = azurerm_storage_account.storageaccount.primary_blob_endpoint
  instanceType = var.instanceType["proxy"]
  tags         = var.tags
}
