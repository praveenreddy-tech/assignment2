provider "azurerm" {
  features {}
}

# Random string for uniqueness
resource "random_integer" "rand" {
  min = 1000
  max = 9999
}

# 1. Resource Group
resource "azurerm_resource_group" "terra" {
  name     = "terra-rg-${random_integer.rand.result}"
  location = "East US"
}

# 2. Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "terra-vnet-${random_integer.rand.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terra.location
  resource_group_name = azurerm_resource_group.terra.name
}

# 3. Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "terra-subnet"
  resource_group_name  = azurerm_resource_group.terra.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "terra-nic-${random_integer.rand.result}"
  location            = azurerm_resource_group.terra.location
  resource_group_name = azurerm_resource_group.terra.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 5. Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "terra-vm-${random_integer.rand.result}"
  resource_group_name = azurerm_resource_group.terra.name
  location            = azurerm_resource_group.terra.location
  size                = "Standard_B2s"
  admin_username      = "azureadmin"
  admin_password      = "P@ssword1234!"  # change this to a secure password
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "osdisk"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
