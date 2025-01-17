#!/bin/bash
set -e
set -o pipefail

# Function to install MariaDB
install_mariadb() {
    echo "Installing MariaDB"
    apt-get update -qq
    apt-get install -y -qq mariadb-client mariadb-server
}

# Function to check MariaDB version
check_mariadb_version() {
    echo "Checking MariaDB version"
    mysql -u root --version
}

# Function to check MariaDB database directory
check_mariadb_directory() {
    echo "Checking MariaDB database directory at /var/lib/mysql"
    ls -al /var/lib/mysql
}

# Main script execution
main() {
    # Run the installation in the background to allow parallel execution
    install_mariadb &

    # Capture the PID of the background process
    INSTALL_PID=$!

    # Wait for the installation to complete
    wait $INSTALL_PID

    # Check MariaDB version and directory in parallel
    check_mariadb_version &
    check_mariadb_directory &

    # Wait for both checks to complete
    wait

    echo "Done installing MariaDB"
}

# Execute the main function
main
