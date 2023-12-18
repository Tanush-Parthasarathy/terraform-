# Configure the Azure provider
provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
 
# Reference the existing resource group
data "azurerm_resource_group" "existing" {
  name = "AUE-KOR-ResourceGroup-TRN01"
}
 
# Create your other resources within the existing resource group, using the "existing" data block
resource "azurerm_virtual_network" "VNet" {
  name                = Sample-vnet
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
}
 
# Create other resources using the data block as a reference
resource "azurerm_subnet" "Subnet" {
  name                 = Sample-subnet
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.VNet.name
  address_prefixes     = ["10.0.1.0/24"]
}
 
resource "azurerm_network_security_group" "NSG" {
  name                = Sample
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
}
 
# Create a network security group rule to allow RDP traffic (port 3389)
resource "azurerm_network_security_rule" "NSR" {
  name                        = "rdp"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.existing.name
  network_security_group_name = azurerm_network_security_group.NSG.name
}
 
# Create a network interface for the Windows VM
resource "azurerm_network_interface" "NI" {
  name                = Sample-nic
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
 
# Create a Windows virtual machine
resource "azurerm_virtual_machine" "VM" {
  name                  = Sample-vm
  location              = data.azurerm_resource_group.existing.location
  resource_group_name   = data.azurerm_resource_group.existing.name
  network_interface_ids = [azurerm_network_interface.NI.id]
  vm_size               = "Standard_DS2_v2"
 
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
 
  storage_os_disk {
    name              = "SampleOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
 
  os_profile {
    computer_name  = "Test"
    admin_username = "adminuser"
    admin_password = "Passw@rd123" 
  }
 
  os_profile_windows_config {
    enable_automatic_upgrades = true
  }
 
  tags = {
    environment = "testing"
  }
}
 