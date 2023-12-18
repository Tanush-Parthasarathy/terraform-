
provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
 
data "azurerm_resource_group" "existing" {
  name = "AUE-KOR-ResourceGroup-TRN01"
}
 
resource "azurerm_virtual_network" "example" {
  name                = "jack-network"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  address_space       = ["10.0.0.0/16"]
}
 
resource "azurerm_subnet" "public_subnet" {
  count                = 1
  name                 = "public-subnet-${count.index + 1}"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.${count.index + 1}.0/24"]
}
 
resource "azurerm_subnet" "private_subnet" {
  count                = 1
  name                 = "private-subnet-${count.index + 1}"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.${count.index + 4}.0/24"]
}
 

 
resource "azurerm_network_interface" "example" {
  count               = 1
  name                = "jack-nic"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
 
  ip_configuration {
    name                          = "jack-ip-config"
    subnet_id = azurerm_subnet.private_subnet[count.index % length(azurerm_subnet.private_subnet)].id
 
    private_ip_address_allocation = "Dynamic"
    
  }
}
 
 
# Create Public IP addresses
resource "azurerm_public_ip" "example" {
  count               = 1
  name                = "example-public-ip-${count.index + 1}"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  allocation_method   = "Dynamic"
}
 
# Create Network Security Group
resource "azurerm_network_security_group" "example_nsg" {
  name                = "example-nsg"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
}
 
# Define NSG rules for inbound traffic
resource "azurerm_network_security_rule" "example_inbound_rule" {
  name                        = "inbound-rule"
  resource_group_name         = data.azurerm_resource_group.existing.name
  network_security_group_name = azurerm_network_security_group.example_nsg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
 

 
# Attach NSG to the network interface
resource "azurerm_network_interface_security_group_association" "example_nic_nsg_association" {
  count = var.vm_count
 
  network_interface_id      = azurerm_network_interface.example[count.index % length(azurerm_network_interface.example)].id
  network_security_group_id = azurerm_network_security_group.example_nsg.id
}
 
 
 
# Define NSG rules for inbound traffic for RDP (Windows)
resource "azurerm_network_security_rule" "example_rdp_rule" {
  resource_group_name         = data.azurerm_resource_group.existing.name
  network_security_group_name = azurerm_network_security_group.example_nsg.name
  
  name                        = "rdp-rule"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
 

 
 
resource "azurerm_virtual_machine" "example" {
 
  count                 = var.vm_count
  name                  = "jackwindows-vm-${count.index + 1}"
  resource_group_name   = data.azurerm_resource_group.existing.name
  location              = data.azurerm_resource_group.existing.location
  network_interface_ids = [azurerm_network_interface.example[count.index].id]
  vm_size               = var.prompt_for_input ? var.vm_size : (
                          var.os_type == "windows" ? element(var.windows_instance_types, 0) :
                          var.os_type == "linux" ? element(var.linux_instance_types, 0) : null
                         )
 
 
 
  storage_image_reference {
    publisher = var.os_type == "windows" ? "MicrosoftWindowsServer" : "Canonical"
    offer     = var.os_type == "windows" ? "WindowsServer" : "UbuntuServer"
    sku       = var.os_type == "windows" ? "2019-Datacenter" : "18.04-LTS"
    version   = "latest"
  }
 
  os_profile {
    computer_name  = "example-vm"
    admin_username = "adminuser"
    admin_password = "Password123"
   
  }
 # Windows-specific configuration
dynamic "os_profile_windows_config" {
  for_each = var.os_type == "windows" ? [1] : []
  content {
    provision_vm_agent = true
  }
}
 
# Linux-specific configuration
dynamic "os_profile_linux_config" {
  for_each = var.os_type == "linux" ? [1] : []
  content {
    disable_password_authentication = false
  }
}
  storage_os_disk {
     name              = "test-os-disk-vm-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 128
 
    os_type = var.os_type == "windows" ? "Windows" : "Linux"
  }
 
 
  tags = {
 
 
   
    environment = "dev"
  }
}