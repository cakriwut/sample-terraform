# 1. Create simple resources
# 2. Input / Output parameters
# 3. Destroy resources

resource "azurerm_resource_group" "devops" {
   name = var.resource_group_name
   location  = var.location
   tags  = var.tags
}