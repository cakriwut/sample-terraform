variable "resource_group_name" {
    description = "Resource Group name"
    default = "GAB2020-RG"  
}

variable "location" {
   description = "Resource location"
}

variable "tags" {
   description = "Resource tags"
   type = map(string)
   default =  {
      environment = "dev"
      client     = "gab2020"
   }
}


