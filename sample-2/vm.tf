# 1. Create public_ip , to access the VM
# 2. Assign dynamic FQDN to public IP
# 3. Create NIC , and assign public IP
# 4. Create VM and assign NIC

resource "random_string" "fqdn" {
  length        = 6
  special       = false
  upper         = false
  number        = false
}

resource "azurerm_public_ip" "devops-app" {
 name                         = var.vm_app_base_name
 location                     = azurerm_resource_group.devops.location
 resource_group_name          = azurerm_resource_group.devops.name
 allocation_method            = "Static" 
 domain_name_label            = format("${var.vm_app_base_name}-${random_string.fqdn.result}")
 tags                         = var.tags
}

resource "azurerm_network_interface" "devops-app" {
    name = var.vm_app_base_name
    location = azurerm_resource_group.devops.location
    resource_group_name = azurerm_resource_group.devops.name

    ip_configuration {
        name = "${var.vm_app_base_name}-nic-config"
        subnet_id = azurerm_subnet.devops-app.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.devops-app.id
    }
    tags = var.tags
  
}

resource "azurerm_windows_virtual_machine" "devops-app" {  
   name = var.vm_app_base_name
   location = azurerm_resource_group.devops.location
   resource_group_name = azurerm_resource_group.devops.name
   network_interface_ids = [azurerm_network_interface.devops-app.id]
   size = var.vm_app_size
   admin_username =  var.admin_username
   admin_password = var.admin_password

   source_image_reference {
       publisher = "MicrosoftWindowsServer"
       offer = "WindowsServer"
       sku = "2019-Datacenter"
       version = "latest"
   }

   os_disk {
       caching = "ReadWrite"
       storage_account_type = "Standard_LRS"
   }
}