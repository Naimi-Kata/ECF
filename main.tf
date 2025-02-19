# PROVIDER
provider "azurerm" {
features {}
  # L'attribut `version` est optionnel mais conseillé pour contrôler la version du provider qui sera utilisé.
  # Dans le cas contraire, il sera automatiquement mis à jour par Terraform à chaque exécution.
  version = ">=1.22.0"
  
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  client_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  client_secret   = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

    # Creer un ResourceGroup
    resource "azurerm_resource_group" "myFirstRG" {
        name     = "testRG"
        location = "westeurope"

    }

    # Creer un virtual network
    resource "azurerm_virtual_network" "myFirstVNet" {
        name                = "testVNet"
        address_space       = ["10.0.0.0/16"]
        location            = "westeurope"
        resource_group_name = "${azurerm_resource_group.myFirstRG.name}"

    }

    # Creer un subnet
    resource "azurerm_subnet" "myFirstSubnet" {
        name                 = "testSubnet"
        resource_group_name  = "${azurerm_resource_group.myFirstRG.name}"
        virtual_network_name = "${azurerm_virtual_network.myFirstVNet.name}"
        address_prefixes     = ["10.0.1.0/24"]
    }

    # Créer un Network Security Group 
    resource "azurerm_network_security_group" "myFirstNSG" {
        name                = "testNSG"
        location            = "westeurope"
        resource_group_name = "${azurerm_resource_group.myFirstRG.name}"

        security_rule {
            name                       = "SSH"
            priority                   = 1001
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "22"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
        }

        security_rule {
            name                       = "HTTP"
            priority                   = 1002
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "80"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
        }

        security_rule {
            name                       = "HTTPS"
            priority                   = 1003
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "443"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
        }

    }

    # Créer une IP publique
resource "azurerm_public_ip" "myFirstIP" {
    name                         = "$testPublicIP"
    location                     = "westeurope"
    resource_group_name          = "${azurerm_resource_group.myFirstRG.name}"
    allocation_method = "Dynamic"

}


# Créer une carte réseau
resource "azurerm_network_interface" "myFirstNIC" {
    name                      = "testNIC"
    location                  = "westeurope"
    resource_group_name       = "${azurerm_resource_group.myFirstRG.name}"
    network_security_group_id = "${azurerm_network_security_group.myFirstNSG.id}"

    ip_configuration {
        name                          = "testNICConfig"
        subnet_id                     = "${azurerm_subnet.myFirstSubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myFirstIP.id}"
    }

}

    # Créer une virtual machine
    resource "azurerm_virtual_machine" "myFirstVM" {
        name                  = "testVM"
        location              = "westeurope"
        resource_group_name   = "${azurerm_resource_group.myFirstRG.name}"
        network_interface_ids = ["${azurerm_network_interface.myFirstNIC.id}"]
        vm_size               = "Standard_B1s"

        storage_os_disk {
            name              = "myOsDisk"
            caching           = "ReadWrite"
            create_option     = "FromImage"
            managed_disk_type = "Standard_LRS"
        }

        storage_image_reference {
            publisher = "OpenLogic"
            offer     = "CentOS"
            sku       = "7.6"
            version   = "latest"
        }

        os_profile {
            computer_name  = "testVM"
            admin_username = "user"
        }

        os_profile_linux_config {
            disable_password_authentication = true
            ssh_keys {
                path     = "/home/user/.ssh/authorized_keys"
                key_data = "ssh-rsa test"
            }
        }

    }
