# 1. Create public_ip , to access the VM
# 2. Assign dynamic FQDN to public IP
# 3. Create NIC , and assign public IP
# 4. Create VM and assign NIC

# resource "random_string" "fqdn" {
#   length        = 6
#   special       = false
#   upper         = false
#   number        = false
# }

resource "azurerm_public_ip" "devops-db" {
 count      = var.vm_db_total
 name                         = format("${var.vm_db_base_name}-%02d",count.index)
 location                     = azurerm_resource_group.devops.location
 resource_group_name          = azurerm_resource_group.devops.name
 allocation_method            = "Static" 
 domain_name_label            = format("${var.vm_db_base_name}-${random_string.fqdn.result}-%02d",count.index)
 tags                         = var.tags
}

resource "azurerm_network_interface" "devops-db" {
    count      = var.vm_db_total
    name = format("${var.vm_db_base_name}-%02d",count.index)
    location = azurerm_resource_group.devops.location
    resource_group_name = azurerm_resource_group.devops.name

    ip_configuration {
        name = "${var.vm_db_base_name}-nic-config"
        subnet_id = azurerm_subnet.devops-db.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.devops-db[count.index].id
    }
    tags = var.tags
  
}

resource "azurerm_windows_virtual_machine" "devops-db" {  
   count      = var.vm_db_total
   name = format("${var.vm_db_base_name}-%02d",count.index)
   location = azurerm_resource_group.devops.location
   resource_group_name = azurerm_resource_group.devops.name
   network_interface_ids = [azurerm_network_interface.devops-db[count.index].id]
   size = var.vm_db_size
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