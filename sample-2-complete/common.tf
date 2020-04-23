terraform {
    required_providers {
        azurerm = "~> 2.5"
        random = "~> 2.2"
    }
}

provider "azurerm" {
    features {}  
}