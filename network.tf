resource "azurerm_resource_group" "resource" {
  name     = "webapp-provisioner"
  location = "East US"
}


resource "azurerm_virtual_network" "network" {
  name                = "app-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource.location
  resource_group_name = azurerm_resource_group.resource.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  address_prefixes     = ["10.0.2.0/24"]
  virtual_network_name = azurerm_virtual_network.network.name
  resource_group_name  = azurerm_resource_group.resource.name
}

resource "azurerm_network_security_group" "nsg" {
  name                = "network-nsg"
  location            = azurerm_resource_group.resource.location
  resource_group_name = azurerm_resource_group.resource.name

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
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip"
  location            = azurerm_resource_group.resource.location
  resource_group_name = azurerm_resource_group.resource.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.resource.location
  resource_group_name = azurerm_resource_group.resource.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
