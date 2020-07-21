# Azure Environment
variable projectPrefix { default = "missionowner" }
variable adminUserName { default = "xadmin" }
variable adminPassword { default = "2018F5Networks!!" }
variable adminPubKey { default = "~/.ssh/id_rsa.pub" }
variable location { default = "usgovvirginia" }
variable region { default = "USGov Virginia" }
variable owner { default = "michael@f5.com" }

variable instanceType {
  type = map(string)
  default = {
    "application" = "Standard_DS1_v2"
    "proxy" = "Standard_DS3_v2"
  }
}

variable region_domain { default = "usgovvirginia.cloudapp.usgovcloudapi.net" }

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

variable active_device { default = "proxy01" } 
# mgmt private ips
variable proxy01mgmt { default = "10.100.0.4" }
variable proxy02mgmt { default = "10.100.0.5" }

# external private ips
variable proxy01ext { default = "10.100.1.4" }
variable proxy02ext { default = "10.100.1.5" }

# Example application private ips
variable app01ext { default = "10.100.2.101" }

# internal private ips 
variable proxy01int { default = "10.100.2.4" }
variable proxy02int { default = "10.100.2.5" }

variable tags {
    default = {
        "purpose" = "public" 
        "environment" = "f5env" #ex. dev/staging/prod
        "owner" = "f5owner"
        "group" = "f5group" 
        "costcenter" = "f5costcenter"
        "application" = "f5app"
    }
}