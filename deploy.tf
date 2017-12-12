resource "azurerm_resource_group" "CICD-rg" {
  name     = "CICD-rg"
  location = "West US 2"
}


resource "azurerm_public_ip" "jenkins" {
  name                         = "CICD-pip-jenkins01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.CICD-rg.name}"
  public_ip_address_allocation = "static"

}

resource "azurerm_public_ip" "apache" {
  name                         = "CICD-pip-apache01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.CICD-rg.name}"
  public_ip_address_allocation = "static"

}

resource "azurerm_public_ip" "jdk" {
  name                         = "CICD-pip01-jdk01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.CICD-rg.name}"
  public_ip_address_allocation = "static"

}

resource "azurerm_virtual_network" "CICD-net" {
  name                = "CICD-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.CICD-rg.name}"
}

resource "azurerm_subnet" "CICD-sub" {
  name                 = "CICD-sub"
  resource_group_name  = "${azurerm_resource_group.CICD-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.CICD-net.name}"
  address_prefix       = "10.0.2.0/24"
}



resource "azurerm_network_interface" "jenkins" {
  name                = "CICD-nic-jenkins01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.CICD-rg.name}"

  ip_configuration {
    name                          = "CICD-conf-jenkins01"
    subnet_id                     = "${azurerm_subnet.CICD-sub.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.4"
    public_ip_address_id          = "${azurerm_public_ip.jenkins.id}"
  }
}




resource "azurerm_virtual_machine" "jenkins" {
  name                  = "CICD-vm-jenkins01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.CICD-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.jenkins.id}"]
  vm_size               = "Standard_DS1_v2"

storage_os_disk {
    name              = "CICD-disk-jenkins01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
}

storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
}

os_profile {
    computer_name  = "CICD-vm-jenkins01"
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


resource "azurerm_network_interface" "apache" {
  name                = "CICD-nic-apache01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.CICD-rg.name}"

  ip_configuration {
    name                          = "CICD-conf-apache01"
    subnet_id                     = "${azurerm_subnet.CICD-sub.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.5"
    public_ip_address_id          = "${azurerm_public_ip.apache.id}"
  }
}




resource "azurerm_virtual_machine" "apache" {
  name                  = "CICD-vm-apache01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.CICD-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.apache.id}"]
  vm_size               = "Standard_DS1_v2"

storage_os_disk {
    name              = "CICD-disk-apache01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
}

storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
}

os_profile {
    computer_name  = "CICD-vm-apache01"
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

resource "azurerm_network_interface" "jdk" {
  name                = "CICD-nic-jdk01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.CICD-rg.name}"

  ip_configuration {
    name                          = "CICD-conf-jdk01"
    subnet_id                     = "${azurerm_subnet.CICD-sub.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.6"
    public_ip_address_id          = "${azurerm_public_ip.jdk.id}"
  }
}




resource "azurerm_virtual_machine" "jdk" {
  name                  = "CICD-vm-jdk01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.CICD-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.jdk.id}"]
  vm_size               = "Standard_DS1_v2"

storage_os_disk {
    name              = "CICD-disk-jdk01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
}

storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
}

os_profile {
    computer_name  = "CICD-vm-jdk01"
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
resource_group_name = "${azurerm_resource_group.CICD-rg.name}"
virtual_machine_name = "${azurerm_virtual_machine.jenkins.name}"
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



resource "azurerm_virtual_machine_extension" "apache" {
name = "CustomscriptExtension"
location = "West US 2"
resource_group_name = "${azurerm_resource_group.CICD-rg.name}"
virtual_machine_name = "${azurerm_virtual_machine.apache.name}"
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

resource "azurerm_virtual_machine_extension" "jdk" {
name = "CustomscriptExtension"
location = "West US 2"
resource_group_name = "${azurerm_resource_group.CICD-rg.name}"
virtual_machine_name = "${azurerm_virtual_machine.jdk.name}"
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










output "jenkins_public_ip" {
value = "${azurerm_public_ip.jenkins.ip_address}"
}

output "apache_public_ip" {
value = "${azurerm_public_ip.apache.ip_address}"
}

output "jdk_public_ip" {
value = "${azurerm_public_ip.jdk.ip_address}"
}
























