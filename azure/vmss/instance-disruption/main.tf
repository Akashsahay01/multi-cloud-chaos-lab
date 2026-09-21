terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

variable "location" {
  type    = string
  default = "UK South"
}

variable "vmss_id" {
  type = string
}

provider "azurerm" {
  features {}
}

output "vmss_id" {
  value = var.vmss_id
}
