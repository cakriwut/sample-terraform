# 1. Create Vnet
# 2. Create a subnet
# 3. Create a NSG
# 4. Associate subnet to NSG


resource "azurerm_virtual_network" "devops" {
  name                  = "devops-vnet"
  address_space         = ["10.0.0.0/16"]
  location              = azurerm_resource_group.devops.location
  resource_group_name   = azurerm_resource_group.devops.name
  tags                  = var.tags
}

resource "azurerm_subnet" "devops-app" {
  name                  = "app-subnet"
  resource_group_name   = azurerm_resource_group.devops.name
  virtual_network_name  = azurerm_virtual_network.devops.name
  address_prefix        = "10.0.2.0/24"
}

resource "azurerm_network_security_group" "devops-app" {
  name                  = "devops-nsg-app"
  location              = var.location
  resource_group_name   = azurerm_resource_group.devops.name

  security_rule {
      name                  = "RDP"
      priority              = 1001
      direction             = "Inbound"
      access                = "Allow"
      protocol              = "TCP"
      source_port_range     = "*"
      destination_port_range = "3389"
      source_address_prefix = "*"
      destination_address_prefix = "*"
  }

  security_rule {
      name                  = "HTTP-HTTPS"
      priority              = 1002
      direction             = "Inbound"
      access                = "Allow"
      protocol              = "TCP"
      source_port_range     = "*"
      destination_port_ranges = ["80","443"]
      source_address_prefix = "*"
      destination_address_prefix = "*"
  }

  tags  = var.tags
}

resource "azurerm_subnet_network_security_group_association" "devops-app" {
  subnet_id                 = azurerm_subnet.devops-app.id
  network_security_group_id = azurerm_network_security_group.devops-app.id
}