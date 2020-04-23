output "resource_location" {
  value = azurerm_resource_group.devops.location
}

output "vm_app_name" {
  value = azurerm_public_ip.devops-app.*.fqdn
}
