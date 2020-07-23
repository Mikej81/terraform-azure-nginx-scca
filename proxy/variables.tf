# Azure Environment
variable projectPrefix {  }
variable adminUserName {  }
variable adminPassword {  }
variable adminPubKey {  }
variable location { }
variable region {  }
variable owner { }
variable prefix { }
variable resourceGroup { }
variable securityGroup { }
variable active_device { }
variable missionownermgmt { }
variable missionownerext { }
variable missionownerint { }
variable ssh_key {}
variable storage_account {}
#variable managementPool {}
variable instanceType {}

#variable backendPool { }
# variable proxy1_dns {}
# variable proxy2_dns {}

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