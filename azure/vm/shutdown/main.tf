terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.77"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  type        = string
  description = "Azure region for the Chaos Studio experiment."
  default     = "uksouth"
}

variable "resource_group_name" {
  type        = string
  description = "Existing resource group containing the target VM."
}

variable "target_vm_id" {
  type        = string
  description = "Resource ID of the existing non-production VM."
}

variable "experiment_name" {
  type        = string
  description = "Chaos Studio experiment name."
  default     = "mcl-vm-shutdown"
}

resource "azurerm_chaos_studio_target" "vm" {
  location           = var.location
  target_resource_id = var.target_vm_id
  target_type        = "Microsoft-VirtualMachine"
}

resource "azurerm_chaos_studio_capability" "shutdown" {
  chaos_studio_target_id = azurerm_chaos_studio_target.vm.id
  capability_type        = "Shutdown-1.0"
}

resource "azurerm_chaos_studio_experiment" "vm_shutdown" {
  location            = var.location
  name                = var.experiment_name
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }

  selectors {
    name                    = "vm-selector"
    chaos_studio_target_ids = [azurerm_chaos_studio_target.vm.id]
  }

  steps {
    name = "shutdown-step"

    branch {
      name = "shutdown-branch"

      actions {
        urn           = azurerm_chaos_studio_capability.shutdown.urn
        selector_name = "vm-selector"
        action_type   = "continuous"
        duration      = "PT10M"

        parameters = {
          abruptShutdown = "false"
        }
      }
    }
  }
}

output "experiment_id" {
  value = azurerm_chaos_studio_experiment.vm_shutdown.id
}

output "experiment_principal_id" {
  value = azurerm_chaos_studio_experiment.vm_shutdown.identity[0].principal_id
}

output "target_id" {
  value = azurerm_chaos_studio_target.vm.id
}
