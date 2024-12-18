#!/bin/bash

# This script sets up a basic LAMP stack on Ubuntu 20.04 VPS

# Update the system
echo "Updating system..."
sudo apt update -y && sudo apt upgrade -y

# Install necessary packages
echo "Installing Apache, MySQL, PHP, and other necessary packages..."
sudo apt install -y apache2 mysql-server php php-mysql libapache2-mod-php ufw git

# Install Git if not installed
echo "Installing Git..."
sudo apt install git -y

# Enable and start Apache and MySQL services
echo "Starting Apache and MySQL..."
sudo systemctl enable apache2
sudo systemctl enable mysql
sudo systemctl start apache2
sudo systemctl start mysql

# Setup firewall to allow SSH, HTTP, and HTTPS
echo "Setting up firewall to allow SSH, HTTP, and HTTPS..."
sudo ufw allow OpenSSH
sudo ufw allow 'Apache Full'
sudo ufw enable

# Create a simple test PHP file
echo "Creating a PHP info page..."
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

# Set up SSH Key Authentication (for security)
echo "Setting up SSH key-based authentication..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "Enter the SSH public key to be added to authorized_keys:"
read ssh_key
echo "$ssh_key" > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Remove the default Apache index page
echo "Removing the default Apache index.html..."
sudo rm /var/www/html/index.html

# Restart Apache to apply changes
echo "Restarting Apache..."
sudo systemctl restart apache2

# Displaying success message
echo "LAMP stack setup completed! You can test it by going to your VPS IP or domain in the browser."

# Displaying server IP address
ip_address=$(hostname -I | awk '{print $1}')
echo "Your VPS IP address is: $ip_address"

# Suggest checking server PHP info page
echo "You can access the PHP info page at http://$ip_address/info.php"

# End of setup
echo "Setup completed successfully!"
