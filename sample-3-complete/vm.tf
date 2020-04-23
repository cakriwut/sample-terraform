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
 count      = var.vm_app_total
 name                         = format("${var.vm_app_base_name}-%02d",count.index)
 location                     = azurerm_resource_group.devops.location
 resource_group_name          = azurerm_resource_group.devops.name
 allocation_method            = "Static" 
 domain_name_label            = format("${var.vm_app_base_name}-${random_string.fqdn.result}-%02d",count.index)
 tags                         = var.tags
}

resource "azurerm_network_interface" "devops-app" {
    count      = var.vm_app_total
    name = format("${var.vm_app_base_name}-%02d",count.index)
    location = azurerm_resource_group.devops.location
    resource_group_name = azurerm_resource_group.devops.name

    ip_configuration {
        name = "${var.vm_app_base_name}-nic-config"
        subnet_id = azurerm_subnet.devops-app.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.devops-app[count.index].id
    }
    tags = var.tags
  
}

resource "azurerm_windows_virtual_machine" "devops-app" {  
   count      = var.vm_app_total
   name = format("${var.vm_app_base_name}-%02d",count.index)
   location = azurerm_resource_group.devops.location
   resource_group_name = azurerm_resource_group.devops.name
   network_interface_ids = [azurerm_network_interface.devops-app[count.index].id]
   size = var.vm_app_size
   admin_username =  var.admin_username
   admin_password = var.admin_password

   custom_data = filebase64("app_init.ps1")

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

resource "azurerm_virtual_machine_extension" "devops-app-customscript" {
  count = var.vm_app_total
  name                 = "CustomScript"
  virtual_machine_id   = azurerm_windows_virtual_machine.devops-app[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  
  protected_settings = jsonencode({
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted  -Command \"$env:AdminUser='${var.admin_username}'; $env:AdminPassword='${var.admin_password}'; copy-item c:\\AzureData\\CustomData.bin c:\\init.ps1;& c:\\init.ps1; Remove-Item c:\\Init.ps1 -Force; exit 0;\""
  })

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "devops-app-bginfo" {
  count = var.vm_app_total
  name                 = "BGInfo"
  virtual_machine_id = azurerm_windows_virtual_machine.devops-app[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "BGInfo"
  type_handler_version = "2.1"  
  depends_on           = [azurerm_virtual_machine_extension.devops-app-customscript]
}