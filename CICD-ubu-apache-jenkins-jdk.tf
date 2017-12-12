##
# Shared resource section
##

#Create CICD resource group
resource "azurerm_resource_group" "CICD-rg-ubu" {
  name     = "CICD-rg-ubu02"
  location = "West US 2"
}

#Create CICD virtual network
resource "azurerm_virtual_network" "CICD-net-ubu" {
  name                = "CICD-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.CICD-rg-ubu.name}"
}

#Create CICD virtual subnet
resource "azurerm_subnet" "CICD-sub-ubu" {
  name                 = "CICD-sub-ubu"
  resource_group_name  = "${azurerm_resource_group.CICD-rg-ubu.name}"
  virtual_network_name = "${azurerm_virtual_network.CICD-net-ubu.name}"
  address_prefix       = "10.0.2.0/24"
}

##
# Jenkins VM section
##

resource "azurerm_public_ip" "jenkins-ubu" {
  name                         = "CICD-pip-jenkins-ubu01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.CICD-rg-ubu.name}"
  public_ip_address_allocation = "static"

}

resource "azurerm_network_interface" "jenkins-ubu" {
  name                = "CICD-nic-jenkins-ubu01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.CICD-rg-ubu.name}"

  ip_configuration {
    name                          = "CICD-conf-jenkins-ubu01"
    subnet_id                     = "${azurerm_subnet.CICD-sub-ubu.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.4"
    public_ip_address_id          = "${azurerm_public_ip.jenkins-ubu.id}"
  }
}

resource "azurerm_virtual_machine" "jenkins-ubu" {
  name                  = "CICD-vm-jenkins-ubu01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.CICD-rg-ubu.name}"
  network_interface_ids = ["${azurerm_network_interface.jenkins-ubu.id}"]
  vm_size               = "Standard_DS1_v2"

storage_os_disk {
    name              = "CICD-disk-jenkins-ubu01"
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
    computer_name  = "CICD-vm-jenkins-ubu01"
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
resource_group_name = "${azurerm_resource_group.CICD-rg-ubu.name}"
virtual_machine_name = "${azurerm_virtual_machine.jenkins-ubu.name}"
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

resource "azurerm_public_ip" "apache-ubu" {
  name                         = "CICD-pip-apache-ubu01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.CICD-rg-ubu.name}"
  public_ip_address_allocation = "static"

}

resource "azurerm_network_interface" "apache-ubu" {
  name                = "CICD-nic-apache-ubu01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.CICD-rg-ubu.name}"

  ip_configuration {
    name                          = "CICD-conf-apache-ubu01"
    subnet_id                     = "${azurerm_subnet.CICD-sub-ubu.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.5"
    public_ip_address_id          = "${azurerm_public_ip.apache-ubu.id}"
  }
}




resource "azurerm_virtual_machine" "apache-ubu" {
  name                  = "CICD-vm-apache-ubu01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.CICD-rg-ubu.name}"
  network_interface_ids = ["${azurerm_network_interface.apache-ubu.id}"]
  vm_size               = "Standard_DS1_v2"

storage_os_disk {
    name              = "CICD-disk-apache-ubu01"
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
    computer_name  = "CICD-vm-apache-ubu01"
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


resource "azurerm_virtual_machine_extension" "apache-ubu" {
name = "CustomscriptExtension"
location = "West US 2"
resource_group_name = "${azurerm_resource_group.CICD-rg-ubu.name}"
virtual_machine_name = "${azurerm_virtual_machine.apache-ubu.name}"
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

#Create jdk-ubu public ip
resource "azurerm_public_ip" "jdk-ubu" {
  name                         = "CICD-pip01-jdk-ubu01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.CICD-rg-ubu.name}"
  public_ip_address_allocation = "static"

}


#Create jdk-ubu network interface
resource "azurerm_network_interface" "jdk-ubu" {
  name                = "CICD-nic-jdk-ubu01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.CICD-rg-ubu.name}"

  ip_configuration {
    name                          = "CICD-conf-jdk-ubu01"
    subnet_id                     = "${azurerm_subnet.CICD-sub-ubu.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.6"
    public_ip_address_id          = "${azurerm_public_ip.jdk-ubu.id}"
  }
}



#create jkd VM
resource "azurerm_virtual_machine" "jdk-ubu" {
  name                  = "CICD-vm-jdk-ubu01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.CICD-rg-ubu.name}"
  network_interface_ids = ["${azurerm_network_interface.jdk-ubu.id}"]
  vm_size               = "Standard_DS1_v2"

storage_os_disk {
    name              = "CICD-disk-jdk-ubu01"
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
    computer_name  = "CICD-vm-jdk-ubu01"
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


#Installing pp_agent and the jdk-ubu8
resource "azurerm_virtual_machine_extension" "jdk-ubu" {
name = "CustomscriptExtension"
location = "West US 2"
resource_group_name = "${azurerm_resource_group.CICD-rg-ubu.name}"
virtual_machine_name = "${azurerm_virtual_machine.jdk-ubu.name}"
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


output "jenkins-ubu_public_ip" {
value = "${azurerm_public_ip.jenkins-ubu.ip_address}"
}

output "apache-ubu_public_ip" {
value = "${azurerm_public_ip.apache-ubu.ip_address}"
}

output "jdk-ubu_public_ip" {
value = "${azurerm_public_ip.jdk-ubu.ip_address}"
}

