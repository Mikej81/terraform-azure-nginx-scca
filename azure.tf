# Configure the Microsoft Azure Provider, replace Service Principal and Subscription with your own
provider "azurerm" {
    version = "~> 2.15.0"
    features{}
}

# Create a Resource Group for the new Virtual Machines
resource azurerm_resource_group main {
  name     = "${var.projectPrefix}_rg"
  location = var.location
}

# Create storage account for boot diagnostics
resource azurerm_storage_account storageaccount {
    name                        = "${var.projectPrefix}diag"
    resource_group_name          = azurerm_resource_group.main.name
    location                     = azurerm_resource_group.main.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = var.tags
}

# Create Availability Set
resource azurerm_availability_set avset {
  name                         = "${var.projectPrefix}avset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}