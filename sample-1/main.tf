# 1. Create simple resources
# 2. Input / Output parameters
# 3. Destroy resources

resource "azurerm_resource_group" "devops" {
   name = "GAB2020-RG"
   location  = "southeastasia"
   tags  =  {
      environment = "dev"
      client     = "gab2020"
   }
}