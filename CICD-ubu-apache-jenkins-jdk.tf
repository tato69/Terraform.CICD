##
# Shared resource section
##

#Create CICD resource group
resource "azurerm_resource_group" "CICD-rg-rh" {
  name     = "CICD-rg-rh02"
  location = "West US 2"
}

#Create CICD virtual network
resource "azurerm_virtual_network" "CICD-net-rh" {
  name                = "CICD-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.CICD-rg-rh.name}"
}

#Create CICD virtual subnet
resource "azurerm_subnet" "CICD-sub-rh" {
  name                 = "CICD-sub-rh"
  resource_group_name  = "${azurerm_resource_group.CICD-rg-rh.name}"
  virtual_network_name = "${azurerm_virtual_network.CICD-net-rh.name}"
  address_prefix       = "10.0.2.0/24"
}

##
# Jenkins VM section
##

resource "azurerm_public_ip" "jenkins-rh" {
  name                         = "CICD-pip-jenkins-rh01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.CICD-rg-rh.name}"
  public_ip_address_allocation = "static"

}

resource "azurerm_network_interface" "jenkins-rh" {
  name                = "CICD-nic-jenkins-rh01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.CICD-rg-rh.name}"

  ip_configuration {
    name                          = "CICD-conf-jenkins-rh01"
    subnet_id                     = "${azurerm_subnet.CICD-sub-rh.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.4"
    public_ip_address_id          = "${azurerm_public_ip.jenkins-rh.id}"
  }
}

resource "azurerm_virtual_machine" "jenkins-rh" {
  name                  = "CICD-vm-jenkins-rh01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.CICD-rg-rh.name}"
  network_interface_ids = ["${azurerm_network_interface.jenkins-rh.id}"]
  vm_size               = "Standard_DS1_v2"

storage_os_disk {
    name              = "CICD-disk-jenkins-rh01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
}

storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7.3"
    version   = "latest"
}

os_profile {
    computer_name  = "CICD-vm-jenkins-rh01"
    admin_username = "ariso001a"
    admin_password = "Password123"
}

# Uncomment this line to delete the OS disk automatically when deleting the VM
delete_os_disk_on_termination = true

os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
        path     = "/home/ariso001a/.ssh/authorized_keys"
        key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI4F5FUcgWYxixSkZLmyi5KpyLWAQhy9+eCvGhUmEATWYoIyrgESKKg3pQKD/YafivPo49oA6pkqIJRo3QjyUTBYDpzOKwwkldiAvGwoZyrZKsHAfXy6iQhni6d95kErqqvL82XlYqIaZGx49adHvrZkbuG2XrlLXTOXZYb8L6PfExekyYdkxhgH51a9pnDX08cf59AlgEpSi/evrdRgSgsIm9L8I9CyaHFsOgL04aXFj2+AxTcqaKdnVt0xGfbwxwqNi8o9aANRP3+NvB8/0QCLw1uUXQrV1K0PB/qGNqYjFzgeY0Xq6fTbVFu4uQ9h5596I531IN4dY1mW6mf71p"
    }
}

}

resource "azurerm_virtual_machine_extension" "customscript" {
name = "CustomscriptExtension"
location = "West US 2"
resource_group_name = "${azurerm_resource_group.CICD-rg-rh.name}"
virtual_machine_name = "${azurerm_virtual_machine.jenkins-rh.name}"
publisher = "Microsoft.Azure.Extensions"
type = "CustomScript"
type_handler_version = "2.0"

settings = <<SETTINGS
{
"fileUris": ["https://raw.githubusercontent.com/tato69/Terraform.CICD/master/pp_agent_jenkins.bash"],
"commandToExecute": "sudo ./pp_agent_jenkins.bash"
}
SETTINGS
#closing VM
}


##
# APACHE VM section
##

resource "azurerm_public_ip" "apache-rh" {
  name                         = "CICD-pip-apache-rh01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.CICD-rg-rh.name}"
  public_ip_address_allocation = "static"

}

resource "azurerm_network_interface" "apache-rh" {
  name                = "CICD-nic-apache-rh01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.CICD-rg-rh.name}"

  ip_configuration {
    name                          = "CICD-conf-apache-rh01"
    subnet_id                     = "${azurerm_subnet.CICD-sub-rh.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.5"
    public_ip_address_id          = "${azurerm_public_ip.apache-rh.id}"
  }
}




resource "azurerm_virtual_machine" "apache-rh" {
  name                  = "CICD-vm-apache-rh01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.CICD-rg-rh.name}"
  network_interface_ids = ["${azurerm_network_interface.apache-rh.id}"]
  vm_size               = "Standard_DS1_v2"

storage_os_disk {
    name              = "CICD-disk-apache-rh01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
}

storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7.3"
    version   = "latest"
}

os_profile {
    computer_name  = "CICD-vm-apache-rh01"
    admin_username = "ariso001a"
    admin_password = "Password123"
}

# Uncomment this line to delete the OS disk automatically when deleting the VM
delete_os_disk_on_termination = true

os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
        path     = "/home/ariso001a/.ssh/authorized_keys"
        key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI4F5FUcgWYxixSkZLmyi5KpyLWAQhy9+eCvGhUmEATWYoIyrgESKKg3pQKD/YafivPo49oA6pkqIJRo3QjyUTBYDpzOKwwkldiAvGwoZyrZKsHAfXy6iQhni6d95kErqqvL82XlYqIaZGx49adHvrZkbuG2XrlLXTOXZYb8L6PfExekyYdkxhgH51a9pnDX08cf59AlgEpSi/evrdRgSgsIm9L8I9CyaHFsOgL04aXFj2+AxTcqaKdnVt0xGfbwxwqNi8o9aANRP3+NvB8/0QCLw1uUXQrV1K0PB/qGNqYjFzgeY0Xq6fTbVFu4uQ9h5596I531IN4dY1mW6mf71p"
    }
}

}


resource "azurerm_virtual_machine_extension" "apache-rh" {
name = "CustomscriptExtension"
location = "West US 2"
resource_group_name = "${azurerm_resource_group.CICD-rg-rh.name}"
virtual_machine_name = "${azurerm_virtual_machine.apache-rh.name}"
publisher = "Microsoft.Azure.Extensions"
type = "CustomScript"
type_handler_version = "2.0"

settings = <<SETTINGS
{
"fileUris": ["https://raw.githubusercontent.com/tato69/Terraform.CICD/master/pp_agent_apache.bash"],
"commandToExecute": "sudo ./pp_agent_apache.bash"
}
SETTINGS
#closing VM
}


##
# JDK VM section
##

#Create jdk-rh public ip
resource "azurerm_public_ip" "jdk-rh" {
  name                         = "CICD-pip01-jdk-rh01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.CICD-rg-rh.name}"
  public_ip_address_allocation = "static"

}


#Create jdk-rh network interface
resource "azurerm_network_interface" "jdk-rh" {
  name                = "CICD-nic-jdk-rh01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.CICD-rg-rh.name}"

  ip_configuration {
    name                          = "CICD-conf-jdk-rh01"
    subnet_id                     = "${azurerm_subnet.CICD-sub-rh.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.6"
    public_ip_address_id          = "${azurerm_public_ip.jdk-rh.id}"
  }
}



#create jkd VM
resource "azurerm_virtual_machine" "jdk-rh" {
  name                  = "CICD-vm-jdk-rh01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.CICD-rg-rh.name}"
  network_interface_ids = ["${azurerm_network_interface.jdk-rh.id}"]
  vm_size               = "Standard_DS1_v2"

storage_os_disk {
    name              = "CICD-disk-jdk-rh01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
}

storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7.3"
    version   = "latest"
}

os_profile {
    computer_name  = "CICD-vm-jdk-rh01"
    admin_username = "ariso001a"
    admin_password = "Password123"
}

# Uncomment this line to delete the OS disk automatically when deleting the VM
delete_os_disk_on_termination = true

os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
        path     = "/home/ariso001a/.ssh/authorized_keys"
        key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI4F5FUcgWYxixSkZLmyi5KpyLWAQhy9+eCvGhUmEATWYoIyrgESKKg3pQKD/YafivPo49oA6pkqIJRo3QjyUTBYDpzOKwwkldiAvGwoZyrZKsHAfXy6iQhni6d95kErqqvL82XlYqIaZGx49adHvrZkbuG2XrlLXTOXZYb8L6PfExekyYdkxhgH51a9pnDX08cf59AlgEpSi/evrdRgSgsIm9L8I9CyaHFsOgL04aXFj2+AxTcqaKdnVt0xGfbwxwqNi8o9aANRP3+NvB8/0QCLw1uUXQrV1K0PB/qGNqYjFzgeY0Xq6fTbVFu4uQ9h5596I531IN4dY1mW6mf71p"
    }
}

}


#Installing pp_agent and the jdk-rh8
resource "azurerm_virtual_machine_extension" "jdk-rh" {
name = "CustomscriptExtension"
location = "West US 2"
resource_group_name = "${azurerm_resource_group.CICD-rg-rh.name}"
virtual_machine_name = "${azurerm_virtual_machine.jdk-rh.name}"
publisher = "Microsoft.Azure.Extensions"
type = "CustomScript"
type_handler_version = "2.0"

settings = <<SETTINGS
{
"fileUris": ["https://raw.githubusercontent.com/tato69/Terraform.CICD/master/pp_agent_jdk.bash"],
"commandToExecute": "sudo ./pp_agent_jdk.bash"
}
SETTINGS
#closing VM
}



##
# OUTPUT section
##


output "jenkins-rh_public_ip" {
value = "${azurerm_public_ip.jenkins-rh.ip_address}"
}

output "apache-rh_public_ip" {
value = "${azurerm_public_ip.apache-rh.ip_address}"
}

output "jdk-rh_public_ip" {
value = "${azurerm_public_ip.jdk-rh.ip_address}"
}

