resource "azurerm_resource_group" "test" {
  name     = "CI-CD-pipeline-test"
  location = "West US 2"
}

resource "azurerm_public_ip" "test" {
  name                         = "CI-CD-pipeline-test-pip01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.test.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "CI-CD-pipeline-test-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.test.name}"
  dns_servers         = ["10.0.2.4" , "8.8.8.8"]
}

resource "azurerm_subnet" "test" {
  name                 = "CI-CD-pipeline-test-sub"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "test" {
  name                = "CI-CD-pipeline-test-nic01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.test.name}"

  ip_configuration {
    name                          = "CI-CD-pipeline-test-conf01"
    subnet_id                     = "${azurerm_subnet.test.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.4"
    public_ip_address_id          = "${azurerm_public_ip.test.id}"
  }
}




resource "azurerm_virtual_machine" "jenkins" {
  name                  = "CI-CD-pipeline-test-vm01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  network_interface_ids = ["${azurerm_network_interface.test.id}"]
  vm_size               = "Standard_DS1_v2"

storage_os_disk {
    name              = "CI-CD-pipeline-test-disk01"
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
    computer_name  = "CI-CD-pipeline-test-vm01"
    admin_username = "ariso001a"
	admin_password = "Password123"
}

# Uncomment this line to delete the OS disk automatically when deleting the VM
delete_os_disk_on_termination = true

os_profile_linux_config {
    disable_password_authentication = false
}

provisioner "file" {
  source      = "./pp_agent_jenkins.bash"
  destination = "/tmp/pp_agent_jenkins.bash"
}

provisioner "remote-exec" {
  inline = [
    "chmod +x /tmp/pp_agent_jenkins.bash",
    "/tmp/pp_agent_jenkins.bash",
  ]
}

}

