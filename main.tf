terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}
provider "random" {}
provider "template" {}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

locals {
  arc = {
    tenant_id                = data.azurerm_subscription.current.tenant_id
    subscription_id          = data.azurerm_subscription.current.subscription_id
    service_principal_appid  = azuread_service_principal.arc.application_id
    service_principal_secret = random_password.arc.result
    resource_group_name      = azurerm_resource_group.arcdemo.name
    location                 = azurerm_resource_group.arcdemo.location
  }
  uniq = substr(sha1(azurerm_resource_group.arcresources.id), 0, 8)
}

// Resource groups

resource "azurerm_resource_group" "arcdemo" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_role_assignment" "arc" {
  role_definition_name = "Azure Connected Machine Onboarding"
  principal_id         = azuread_service_principal.arc.id
  scope                = azurerm_resource_group.arcdemo.id
}

resource "azurerm_resource_group" "arcresources" {
  name     = "${var.resource_group_name}-resources"
  location = var.location
}

// Onboarding service principal

resource "azuread_application" "arc" {
  display_name = "arc-${data.azurerm_subscription.current.subscription_id}"
}

resource "azuread_service_principal" "arc" {
  application_id = azuread_application.arc.application_id
}

resource "random_pet" "arc" {}

resource "random_password" "arc" {
  length           = 16
  special          = true
  override_special = "!@#%()-_"

  keepers = {
    service_principal = azuread_service_principal.arc.id
  }
}

resource "azuread_service_principal_password" "arc" {
  service_principal_id = azuread_service_principal.arc.id
  value                = random_password.arc.result
  end_date             = timeadd(timestamp(), "8760h")

  lifecycle {
    ignore_changes = [end_date]
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

// Networking

resource "azurerm_application_security_group" "linux" {
  name                = "arc-demo-linux-asg"
  location            = azurerm_resource_group.arcresources.location
  resource_group_name = azurerm_resource_group.arcresources.name
}

resource "azurerm_application_security_group" "windows" {
  name                = "arc-demo-windows-asg"
  location            = azurerm_resource_group.arcresources.location
  resource_group_name = azurerm_resource_group.arcresources.name
}

resource "azurerm_network_security_group" "arc" {
  name                = "arc-demo-nsg"
  location            = azurerm_resource_group.arcresources.location
  resource_group_name = azurerm_resource_group.arcresources.name
}

resource "azurerm_network_security_rule" "ssh" {
  resource_group_name         = azurerm_resource_group.arcresources.name
  network_security_group_name = azurerm_network_security_group.arc.name

  name                                       = "SSH"
  priority                                   = 1000
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_address_prefix                      = "*"
  source_port_range                          = "*"
  destination_application_security_group_ids = [azurerm_application_security_group.linux.id]
  destination_port_range                     = "22"
}

resource "azurerm_network_security_rule" "rdp" {
  resource_group_name         = azurerm_resource_group.arcresources.name
  network_security_group_name = azurerm_network_security_group.arc.name

  name                                       = "RDP"
  priority                                   = 1001
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_address_prefix                      = "*"
  source_port_range                          = "*"
  destination_application_security_group_ids = [azurerm_application_security_group.windows.id]
  destination_port_range                     = "3389"
}

resource "azurerm_network_security_rule" "winrm" {
  resource_group_name         = azurerm_resource_group.arcresources.name
  network_security_group_name = azurerm_network_security_group.arc.name

  name                                       = "WinRm"
  priority                                   = 1002
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_address_prefix                      = "*"
  source_port_range                          = "*"
  destination_application_security_group_ids = [azurerm_application_security_group.windows.id]
  destination_port_ranges                    = ["5985", "5986"]
}

resource "azurerm_virtual_network" "arc" {
  name                = "arc-demo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.arcresources.location
  resource_group_name = azurerm_resource_group.arcresources.name
}

resource "azurerm_subnet" "arc" {
  name                 = "arc-demo-subnet"
  resource_group_name  = azurerm_resource_group.arcresources.name
  virtual_network_name = azurerm_virtual_network.arc.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "arc" {
  subnet_id                 = azurerm_subnet.arc.id
  network_security_group_id = azurerm_network_security_group.arc.id
}

// Linux virtual machines

module "linux_vms" {
  source              = "./linux"
  resource_group_name = azurerm_resource_group.arcresources.name
  location            = azurerm_resource_group.arcresources.location
  tags                = var.tags

  for_each = toset(var.linux_vm_names)

  name      = each.value
  dns_label = "arclinuxvm-${local.uniq}-${each.value}"
  subnet_id = azurerm_subnet.arc.id
  asg_id    = azurerm_application_security_group.linux.id

  arc = local.arc
}
