#!/bin/bash
set -e
set -o pipefail

# Function to create SSL certificate and key
create_ssl_certificate() {
    openssl req -x509 -out localhost.crt -keyout localhost.key \
        -newkey rsa:2048 -nodes -sha256 \
        -subj '/CN=localhost' -extensions EXT -config <( \
           printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
}

# Function to create necessary directories
create_directories() {
    sudo mkdir -p /etc/ssl/private /etc/ssl/certs
}

# Function to move the key and certificate to appropriate directories
move_ssl_files() {
    sudo mv localhost.key /etc/ssl/private/
    sudo mv localhost.crt /etc/ssl/certs/
}

# Main script execution
main() {
    # Run directory creation in the background
    create_directories &
    dir_pid=$!

    # Create SSL certificate and key
    create_ssl_certificate
    echo 'SSL certificate and key created'

    # Wait for directory creation to complete
    wait $dir_pid

    # Move SSL certificate and key to the appropriate directories
    move_ssl_files
    echo 'SSL certificate and key moved to /etc/ssl/private and /etc/ssl/certs'
}

# Execute main function
main
