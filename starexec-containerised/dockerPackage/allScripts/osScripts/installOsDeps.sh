#!/bin/bash
set -e
set -o pipefail

# Function to install a package if not already installed
install_if_not_installed() {
    if ! dpkg -l | grep -q "$1"; then
        sudo apt-get install -y "$1"
    else
        echo "$1 is already installed"
    fi
}

# Update package list and upgrade packages
echo "Updating and upgrading package list"
sudo apt-get update && sudo apt-get upgrade -y

# Install essential packages in the background
echo "Installing essential packages"
install_if_not_installed curl &
install_if_not_installed git &
install_if_not_installed wget &
install_if_not_installed unzip &
install_if_not_installed file &
install_if_not_installed apache2 &
install_if_not_installed apache2-utils &
install_if_not_installed tcsh &
install_if_not_installed libnuma-dev &

# Wait for all background processes to complete
wait

# Enable SSL module for Apache
echo "Enabling SSL module for Apache"
sudo a2enmod ssl

# Install development tools in the background
echo "Installing development tools"
install_if_not_installed build-essential &
install_if_not_installed libssl-dev &
install_if_not_installed openssl &

# Wait for all background processes to complete
wait

# Create SSL certificate for localhost for HTTPS
echo "Creating SSL certificate for localhost"
bash ./allScripts/osScripts/SSLCreateLocalhost.sh

# Install DNS utilities in the background
echo "Installing DNS utilities"
install_if_not_installed dnsutils &

# Wait for all background processes to complete
wait

echo "All installations are complete"
