terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

locals {
  uniq      = substr(sha1(data.azurerm_resource_group.arc.id), 0, 8)
  dns_label = var.dns_label_prefix != "" ? "${var.dns_label_prefix}-${var.name}" : "arclinuxvm-${local.uniq}-${var.name}"
}

data "azurerm_resource_group" "arc" {
  name = var.resource_group_name
}

data "template_cloudinit_config" "multipart" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "install_azure_cli"
    content_type = "text/cloud-config"
    content      = file("${path.module}/cloud_init/azure_cli.yaml")
  }

  part {
    filename     = "remove_azure_agent_block_imds"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/cloud_init/azure_agent_imds.tpl", { hostname = var.name })
  }

  part {
    filename     = "install_azcmagent"
    content_type = "text/cloud-config"
    content      = file("${path.module}/cloud_init/azcmagent_install.yaml")
  }

  part {
    filename     = "connect_azcmagent"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/cloud_init/azcmagent_connect.yaml", merge({hostname = var.name}, var.arc))
  }
}

resource "azurerm_public_ip" "arc" {
  name                = "${var.name}-pip"
  resource_group_name = data.azurerm_resource_group.arc.name
  location            = data.azurerm_resource_group.arc.location
  tags                = var.tags

  allocation_method = "Static"
  domain_name_label = local.dns_label
}

resource "azurerm_network_interface" "arc" {
  name                = "${var.name}-nic"
  resource_group_name = data.azurerm_resource_group.arc.name
  location            = data.azurerm_resource_group.arc.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.arc.id
  }
}

resource "azurerm_network_interface_application_security_group_association" "arc" {
  network_interface_id          = azurerm_network_interface.arc.id
  application_security_group_id = var.asg_id
}

resource "azurerm_linux_virtual_machine" "arc" {
  name                = var.name
  resource_group_name = data.azurerm_resource_group.arc.name
  location            = data.azurerm_resource_group.arc.location
  tags                = var.tags

  admin_username                  = var.admin_username
  disable_password_authentication = true
  size                            = var.size

  network_interface_ids = [azurerm_network_interface.arc.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.name}-os"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  // custom_data = filebase64("${path.module}/example_cloud_init")

  // custom_data = base64encode(templatefile("${path.module}/azure_arc_cloud_init.tpl", { hostname = var.name }))
  custom_data = base64encode(data.template_cloudinit_config.multipart.rendered)

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_ssh_key_file)
  }
}
