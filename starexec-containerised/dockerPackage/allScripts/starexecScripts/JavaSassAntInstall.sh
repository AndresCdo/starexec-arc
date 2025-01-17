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

# Update package list
echo "Updating package list"
sudo apt-get update

# Install Java OpenJDK 8 in the background
echo "Installing Java OpenJDK"
install_if_not_installed openjdk-8-jdk &

# Install Ant in the background
echo "Installing Ant"
install_if_not_installed ant &

# Install build essentials for Node.js in the background
echo "Installing build essentials"
install_if_not_installed gcc &
install_if_not_installed g++ &
install_if_not_installed make &

# Wait for all background processes to complete
wait

# Install Node.js using NodeSource official setup script for Node.js 16.x
echo "Downloading and installing Node.js"
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
install_if_not_installed nodejs

# Install Sass globally using npm
echo "Installing Sass"
sudo npm install -g sass

echo "All installations are complete"
