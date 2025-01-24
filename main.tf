provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "palo_alto_rg" {
  name     = "palo-alto-firewall-rg"
  location = "Central US"
}

resource "azurerm_virtual_network" "palo_alto_vnet" {
  name                = "palo-alto-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.palo_alto_rg.location
  resource_group_name = azurerm_resource_group.palo_alto_rg.name
}

resource "azurerm_subnet" "palo_alto_subnet" {
  name                 = "palo-alto-subnet"
  resource_group_name  = azurerm_resource_group.palo_alto_rg.name
  virtual_network_name = azurerm_virtual_network.palo_alto_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "palo_alto_nic" {
  name                = "palo-alto-nic"
  location            = azurerm_resource_group.palo_alto_rg.location
  resource_group_name = azurerm_resource_group.palo_alto_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.palo_alto_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "palo_alto_vm" {
  name                  = "palo-alto-vm"
  location              = azurerm_resource_group.palo_alto_rg.location
  resource_group_name   = azurerm_resource_group.palo_alto_rg.name
  network_interface_ids = [azurerm_network_interface.palo_alto_nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "palo_alto_os_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "PaloAltoNetworks"
    offer     = "vmseries1"
    sku       = "byol"
    version   = "latest"
  }

  os_profile {
    computer_name  = "palo-alto"
    admin_username = "adminuser"
    admin_password = "P@ssword123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}