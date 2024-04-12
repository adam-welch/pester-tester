terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features { }
}

variable "website_name" {
  description = "The name of your static website."
}

module "staticwebpage" {
  source       = "../../module/website"
  location     = "West US"
  website_name = var.website_name
  html_path    = "empty.html"
}