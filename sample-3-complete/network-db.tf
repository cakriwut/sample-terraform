
# 5. Create DB subnet
# 6. Create DB NSG
# 7. Associate DB subnet to NSG

resource "azurerm_subnet" "devops-db" {
  name                  = "db-subnet"
  resource_group_name   = azurerm_resource_group.devops.name
  virtual_network_name  = azurerm_virtual_network.devops.name
  address_prefix        = "10.0.3.0/24"
}

resource "azurerm_network_security_group" "devops-db" {
  name                  = "devops-nsg-db"
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


  tags  = var.tags
}

resource "azurerm_subnet_network_security_group_association" "devops-db" {
  subnet_id                 = azurerm_subnet.devops-db.id
  network_security_group_id = azurerm_network_security_group.devops-db.id
}