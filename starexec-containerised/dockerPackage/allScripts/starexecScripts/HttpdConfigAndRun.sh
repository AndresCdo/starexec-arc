#!/bin/bash
set -e
set -o pipefail

# Function to enable Apache modules in parallel
enable_modules() {
    modules=("proxy" "headers" "proxy_http" "rewrite")
    for module in "${modules[@]}"; do
        sudo a2enmod "$module" &
    done
    wait
}

# Function to disable default sites in parallel
disable_sites() {
    sites=("000-default.conf" "default-ssl.conf")
    for site in "${sites[@]}"; do
        sudo a2dissite "$site" &
    done
    wait
}

# Function to enable custom sites in parallel
enable_sites() {
    sites=("ssl" "starexec")
    for site in "${sites[@]}"; do
        sudo a2ensite "$site" &
    done
    wait
}

# Function to copy configuration files in parallel
copy_config_files() {
    cp ./configFiles/ssl.conf /etc/apache2/sites-available/ &
    cp ./configFiles/starexec.conf /etc/apache2/sites-available/ &
    wait
}

# Function to create logs directory if it doesn't exist
create_logs_directory() {
    sudo mkdir -p /etc/apache2/logs/
}

# Main function to orchestrate the script execution
main() {
    # Copy config files for Apache in parallel
    copy_config_files

    # Disable default sites in parallel
    disable_sites

    # Enable custom sites in parallel
    enable_sites

    # Enable necessary Apache modules in parallel
    enable_modules

    # Create logs directory
    create_logs_directory

    # Reload Apache to apply changes
    sudo service apache2 restart

    # Run Apache in the foreground
    sudo /usr/sbin/apache2ctl -D FOREGROUND
}

# Execute the main function
main
