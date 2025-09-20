resource "azurerm_linux_virtual_machine" "webapp" {
  name                  = "app-vm"
  location              = azurerm_resource_group.resource.location
  resource_group_name   = azurerm_resource_group.resource.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B1s"

  depends_on = [null_resource.pre_deployment]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "demovm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/Users/shood/Dev/infra_code/web-app/ssh.pub")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "echo '<html><body><h1>Keep learning Joy is Coming!</h1></body></html>' | sudo tee /var/www/html/index.html",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      user        = "azureuser"
      private_key = file("/Users/shood/Dev/infra_code/web-app/ssh")
      host        = azurerm_public_ip.public_ip.ip_address
    }
  }

  provisioner "file" {
    source      = "configs/sample.conf"
    destination = "/home/azureuser/sample.conf"

    connection {
      type        = "ssh"
      user        = "azureuser"
      private_key = file("/Users/shood/Dev/infra_code/web-app/ssh")
      host        = azurerm_public_ip.public_ip.ip_address
    }
  }
}
