# Azure Environment
variable projectPrefix { default = "missionowner" }
variable adminUserName { default = "xadmin" }
variable adminPassword { default = "2018F5Networks!!" }
variable adminPubKey { default = "~/.ssh/id_rsa.pub" }
variable location { default = "usgovvirginia" }
variable region { default = "USGov Virginia" }
variable owner { default = "michael@f5.com" }
variable prefix {
  default = "scca"
}
variable resourceGroup {
    default = "scca-tf-rg"
}
variable securityGroup {
  default = "none"
}

variable active_device {}
variable missionownermgmt { }
variable missionownerext { }
variable missionownerint { }
variable ssh_key {}
variable storage_account {}
variable managementPool {}
variable instanceType {}

variable backendPool {
  description = "azureLB resource pool"
}

# NETWORK
variable cidr { default = "10.100.0.0/16" }
variable subnets {
  type = map(string)
  default = {
    "management" = "10.100.0.0/24"
    "data_ext" = "10.100.1.0/24"
    "data_int" = "10.100.2.0/24"
  }
}

variable pip_dns {}
variable availabilitySet { }

# mgmt private ips
variable proxy01mgmt {  }
variable proxy02mgmt {  }

# external private ips
variable proxy01ext { }
variable proxy02ext {  }

# Example application private ips
variable app01ext {  }

# internal private ips 
variable proxy01int {  }
variable proxy02int {  }

variable tags { }