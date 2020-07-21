
variable prefix {
  default = "scca"
}
variable resourceGroup {
    default = "scca-tf-rg"
}
variable securityGroup {
  default = "none"
}

variable missionownermgmt {
  default = "none"
}

variable ssh_key {}

# Azure Environment
variable projectPrefix {  }
variable adminUserName {  }
variable adminPassword {  }
variable location {  }
variable region {  }
variable instanceType {}

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

# Example application private ips
variable app01ext {  }

variable tags { }