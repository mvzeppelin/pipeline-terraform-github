resource "azurerm_resource_group" "rg-vm" {
  name     = "rg-vm"
  location = "West Europe"

  tags = local.common_tags
}

resource "azurerm_public_ip" "public-ip" {
  name                = "public-ip-terraform"
  resource_group_name = azurerm_resource_group.rg-vm.name
  location            = azurerm_resource_group.rg-vm.location
  allocation_method   = "Dynamic"

  tags = local.common_tags
}

resource "azurerm_network_interface" "network-interface" {
  name                = "nic-terraform"
  location            = azurerm_resource_group.rg-vm.location
  resource_group_name = azurerm_resource_group.rg-vm.name

  ip_configuration {
    name                          = "public-ip-terraform"
    subnet_id                     = data.terraform_remote_state.vnet.outputs.subnet_id
    public_ip_address_id          = azurerm_public_ip.public-ip.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.common_tags
}

resource "azurerm_network_interface_security_group_association" "sg-association" {
  network_interface_id      = azurerm_network_interface.network-interface.id
  network_security_group_id = data.terraform_remote_state.vnet.outputs.securit_group_id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-terraform"
  resource_group_name = azurerm_resource_group.rg-vm.name
  location            = azurerm_resource_group.rg-vm.location
  size                = "Standard_B1s"
  admin_username      = "terraform"
  network_interface_ids = [
    azurerm_network_interface.network-interface.id,
  ]

  admin_ssh_key {
    username   = "terraform"
    public_key = var.azure_key_pub
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}