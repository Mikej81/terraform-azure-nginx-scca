# Create (and display) an SSH key
resource tls_private_key ssh {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# output "tls_private_key" { value = "${tls_private_key.ssh.private_key_pem}" }
# output "tls_private_key" { value = "${tls_private_key.ssh.public_key_openssh}" }

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
  source           = "./proxy"
  prefix           = var.projectPrefix
  resourceGroup    = azurerm_resource_group.main
  adminPubKey      = var.adminPubKey
  ssh_key          = chomp(tls_private_key.ssh.public_key_openssh)
  region           = var.region
  location         = var.location
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
  availabilitySet = azurerm_availability_set.avset
  storage_account = azurerm_storage_account.storageaccount.primary_blob_endpoint
  instanceType    = var.instanceType["proxy"]
  owner           = var.owner
  tags            = var.tags
}

output proxy1 {
  value = module.nginx_proxy.proxy1_url
}
output proxy2 {
  value = module.nginx_proxy.proxy2_url
}
output app_ssh {
  value = module.nginx_proxy.app_ssh_url
}