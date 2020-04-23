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

variable "admin_username" {
   description = "VM username"
}

variable "admin_password" {
   description = "VM password"
}


variable "vm_app_base_name" {
   description = "App VM basename"
   default = "app"  
}

variable "vm_app_size" {
   description = "VM Size"
   default = "Standard_B4ms"
}



