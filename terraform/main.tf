# Student Management System - Azure Infrastructure
# Simple Terraform configuration for Azure Student Free Tier

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Resource Group
resource "azurerm_resource_group" "sms_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "StudentManagementSystem"
    ManagedBy   = "Terraform"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "sms_vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sms_rg.location
  resource_group_name = azurerm_resource_group.sms_rg.name

  tags = {
    Environment = var.environment
  }
}

# Subnet for VMs
resource "azurerm_subnet" "sms_subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.sms_rg.name
  virtual_network_name = azurerm_virtual_network.sms_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "sms_nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.sms_rg.location
  resource_group_name = azurerm_resource_group.sms_rg.name

  # SSH
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

  # HTTP
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

  # HTTPS
  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Backend API (8080)
  security_rule {
    name                       = "Backend"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Frontend (5173)
  security_rule {
    name                       = "Frontend"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5173"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Nagios (varies - we'll use default)
  security_rule {
    name                       = "Nagios"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
  }
}

# Public IP for App VM
resource "azurerm_public_ip" "app_vm_pip" {
  name                = "${var.prefix}-app-pip"
  location            = azurerm_resource_group.sms_rg.location
  resource_group_name = azurerm_resource_group.sms_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
  }
}

# Network Interface for App VM
resource "azurerm_network_interface" "app_vm_nic" {
  name                = "${var.prefix}-app-nic"
  location            = azurerm_resource_group.sms_rg.location
  resource_group_name = azurerm_resource_group.sms_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sms_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app_vm_pip.id
  }

  tags = {
    Environment = var.environment
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "app_vm_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.app_vm_nic.id
  network_security_group_id = azurerm_network_security_group.sms_nsg.id
}

# Application VM (Free Tier: B1s)
resource "azurerm_linux_virtual_machine" "app_vm" {
  name                = "${var.prefix}-app-vm"
  resource_group_name = azurerm_resource_group.sms_rg.name
  location            = azurerm_resource_group.sms_rg.location
  size                = "Standard_B1s" # Free tier: 1 vCPU, 1GB RAM
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.app_vm_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = var.environment
    Role        = "Application"
  }
}

# Public IP for Monitor VM
resource "azurerm_public_ip" "monitor_vm_pip" {
  name                = "${var.prefix}-monitor-pip"
  location            = azurerm_resource_group.sms_rg.location
  resource_group_name = azurerm_resource_group.sms_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
  }
}

# Network Interface for Monitoring VM
resource "azurerm_network_interface" "monitor_vm_nic" {
  name                = "${var.prefix}-monitor-nic"
  location            = azurerm_resource_group.sms_rg.location
  resource_group_name = azurerm_resource_group.sms_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sms_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.monitor_vm_pip.id
  }

  tags = {
    Environment = var.environment
  }
}

# Associate NSG with Monitoring NIC
resource "azurerm_network_interface_security_group_association" "monitor_vm_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.monitor_vm_nic.id
  network_security_group_id = azurerm_network_security_group.sms_nsg.id
}

# Monitoring VM for Nagios (Free Tier: B1s)
resource "azurerm_linux_virtual_machine" "monitor_vm" {
  name                = "${var.prefix}-monitor-vm"
  resource_group_name = azurerm_resource_group.sms_rg.name
  location            = azurerm_resource_group.sms_rg.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.monitor_vm_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = var.environment
    Role        = "Monitoring"
  }
}

# PostgreSQL Flexible Server (Free Tier: B1ms)
resource "azurerm_postgresql_flexible_server" "sms_db" {
  name                   = "${var.prefix}-psql-server"
  resource_group_name    = azurerm_resource_group.sms_rg.name
  location               = azurerm_resource_group.sms_rg.location
  version                = "15"
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  storage_mb             = 32768 # 32GB minimum
  sku_name               = "B_Standard_B1ms"
  backup_retention_days  = 7
  zone                   = "1"

  tags = {
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [zone]
  }
}

# PostgreSQL Firewall Rule - Allow Azure Services
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.sms_db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# PostgreSQL Firewall Rule - Allow All (For classroom demo only!)
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name             = "AllowAll"
  server_id        = azurerm_postgresql_flexible_server.sms_db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "sms_database" {
  name      = "sms"
  server_id = azurerm_postgresql_flexible_server.sms_db.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
