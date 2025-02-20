provider "azurerm" {
  features {}
  subscription_id = "5f54abf4-4d29-476e-8042-02236679dba8"
}

resource "azurerm_resource_group" "newVm" {
  name     = "ECF-ResourceGroup"
  location = "westeurope"
}

resource "azurerm_virtual_network" "newVm" {
  name                = "ECF-NET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.newVm.location
  resource_group_name = azurerm_resource_group.newVm.name
}

resource "azurerm_subnet" "newVm" {
  name                 = "ECF-Subnet"
  resource_group_name  = azurerm_resource_group.newVm.name
  virtual_network_name = azurerm_virtual_network.newVm.name
  address_prefixes    = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "newVm" {
  name                = "ECF-NIC"
  location            = azurerm_resource_group.newVm.location
  resource_group_name = azurerm_resource_group.newVm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.newVm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "newVm" {
  name                  = "ECF-VM"
  location              = azurerm_resource_group.newVm.location
  resource_group_name   = azurerm_resource_group.newVm.name
  network_interface_ids = [azurerm_network_interface.newVm.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7_9"
    version   = "latest"
  }

  storage_os_disk {
    name              = "newVmOSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
