#!/bin/bash
set -e

echo "======================================"
echo "Installing Nagios on App VM"
echo "======================================"

# Update system
echo "Updating system packages..."
sudo apt-get update

# Install prerequisites
echo "Installing prerequisites..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 php libapache2-mod-php php-gd \
    build-essential libssl-dev bc gawk dc \
    snmp libnet-snmp-perl gettext autoconf \
    wget unzip apache2-utils

# Create nagios user and groups
echo "Creating Nagios user and groups..."
sudo useradd -m -s /bin/bash nagios || true
sudo groupadd nagcmd || true
sudo usermod -aG nagcmd nagios
sudo usermod -aG nagcmd www-data

# Download and install Nagios Core
echo "Downloading Nagios Core 4.4.14..."
cd /tmp
wget -O nagios-4.4.14.tar.gz https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.4.14/nagios-4.4.14.tar.gz
tar xzf nagios-4.4.14.tar.gz
cd nagios-4.4.14

echo "Compiling Nagios Core..."
./configure --with-nagios-group=nagios --with-command-group=nagcmd
make all
sudo make install
sudo make install-init
sudo make install-commandmode
sudo make install-config
sudo make install-webconf

# Enable Apache modules
echo "Configuring Apache..."
sudo a2enmod rewrite cgi
sudo systemctl restart apache2

# Create nagiosadmin user
echo "Creating nagiosadmin web user..."
sudo htpasswd -bc /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin

# Download and install Nagios Plugins
echo "Downloading Nagios Plugins 2.4.6..."
cd /tmp
wget -O nagios-plugins-2.4.6.tar.gz https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.6/nagios-plugins-2.4.6.tar.gz
tar xzf nagios-plugins-2.4.6.tar.gz
cd nagios-plugins-2.4.6

echo "Compiling Nagios Plugins..."
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make
sudo make install

# Start Nagios
echo "Starting Nagios service..."
sudo systemctl enable nagios
sudo systemctl start nagios

# Restart Apache
sudo systemctl restart apache2

echo "======================================"
echo "✅ Nagios installation completed!"
echo "======================================"
echo "Access Nagios at: http://4.218.12.135/nagios"
echo "Username: nagiosadmin"
echo "Password: nagiosadmin"
echo "======================================"
