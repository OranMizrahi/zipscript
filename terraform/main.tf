# Specify the provider
# Please export ARM_SUBSCRIPTION_ID="CHANGE-TO-SUB-ID"

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg_data_lake_sftp" {
  name     = "rg-data-lake-sftp"
  location = "East US" # Change to your preferred region
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet_data_lake_sftp" {
  name                = "vnet-data-lake-sftp"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_data_lake_sftp.location
  resource_group_name = azurerm_resource_group.rg_data_lake_sftp.name
}

# Create a subnet
resource "azurerm_subnet" "subnet_data_lake_sftp" {
  name                 = "subnet-data-lake-sftp"
  resource_group_name  = azurerm_resource_group.rg_data_lake_sftp.name
  virtual_network_name = azurerm_virtual_network.vnet_data_lake_sftp.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP address
resource "azurerm_public_ip" "ip_data_lake_sftp" {
  name                = "ip-data-lake-sftp"
  location            = azurerm_resource_group.rg_data_lake_sftp.location
  resource_group_name = azurerm_resource_group.rg_data_lake_sftp.name
  allocation_method   = "Static"
}

# Create a network interface
resource "azurerm_network_interface" "nic_data_lake_sftp" {
  name                = "nic-data-lake-sftp"
  location            = azurerm_resource_group.rg_data_lake_sftp.location
  resource_group_name = azurerm_resource_group.rg_data_lake_sftp.name

  ip_configuration {
    name                          = "ip-config-data-lake-sftp"
    subnet_id                     = azurerm_subnet.subnet_data_lake_sftp.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip_data_lake_sftp.id
  }

}


resource "azurerm_network_security_group" "nsg_allow_ssh_data_lake_sftp" {
  name                = "Allow-ssh"
  location            = azurerm_resource_group.rg_data_lake_sftp.location
  resource_group_name = azurerm_resource_group.rg_data_lake_sftp.name

  security_rule {
    name                       = "Allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic_data_lake_sftp.id
  network_security_group_id = azurerm_network_security_group.nsg_allow_ssh_data_lake_sftp.id
}
# Create a Linux virtual machine for SFTP
resource "azurerm_linux_virtual_machine" "vm_data_lake_sftp" {
  name                            = "vm-data-lake-sftp"
  resource_group_name             = azurerm_resource_group.rg_data_lake_sftp.name
  location                        = azurerm_resource_group.rg_data_lake_sftp.location
  size                            = "Standard_B1s"  # Change as needed
  admin_username                  = "sftpuser"      # Change to your preferred username
  admin_password                  = "P@ssw0rd1234!" # Change to a strong password
  disable_password_authentication = "false"

  network_interface_ids = [
    azurerm_network_interface.nic_data_lake_sftp.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# Output the public IP address
output "public_ip" {
  value = azurerm_public_ip.ip_data_lake_sftp.ip_address
}
