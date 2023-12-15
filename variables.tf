variable "client_id" {
  description = "Azure client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure client secret"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}






# Virtual Network
variable "virtual_network_name" {
  description = "The name of the virtual network."
  default = "jackvnet"
  

}

variable "address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "os_publisher" {
  description = "The publisher of the OS image"
  type        = string
  default = "MicrosoftWindowsServer"
}

variable "os_offer" {
  description = "The offer of the OS image"
  type        = string
  default = "WindowsServer"
}

variable "os_sku" {
  description = "The SKU of the OS image"
  type        = string
  default = "2019-Datacenter"
}

variable "os_version" {
  description = "The version of the OS image"
  type        = string
  default = "latest"
}


variable "vm_count" {
  description = "Number of virtual machines to deploy"
  type        = number
  default = "1"
  
}

# Network Interface Card (NIC)
variable "network_interface_name" {
  description = "The name of the network interface card."
  default = "jacknic"
  
}

# Network Security Group (NSG)
variable "nsg_name" {
  description = "The name of the network security group." 
  default = " jacknsg "
}


 
variable "admin_username" {
  description = "The admin username for the virtual machine."
  default = " jackuser"
}
 
variable "admin_password" {
  description = "The admin password for the virtual machine."
  default = "Password123"
}

# Virtual Machine (VM)
variable "virtual_machine_name" {
  description = "The name of the virtual machine."
  default = "jackvm"

  
}

variable "computer_name" {
  description = "The computer name of the virtual machine."
  default = "jackcomp"

  

}


# Virtual Machine Size
variable "vm_size" {
  description = "The size of the virtual machine. Please select the avaliable sizes regarding location "
  default = "Standard_D2_v2"

  # You can customize the default size based on your requirements.
}



variable "prompt_for_input" {
  description = "Flag to prompt the user for input"
  type        = bool
  default     = true
}
