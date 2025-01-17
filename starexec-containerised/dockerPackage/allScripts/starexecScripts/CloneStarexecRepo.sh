#!/bin/bash
set -e
set -o pipefail

# Function to log messages
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

log "Starting the script."

# Function to clone the repository
clone_repo() {
    log "Cloning the repository as starexec user."
    su - starexec -c "git clone -b UMprod --single-branch https://github.com/StarexecMiami/StarExec.git StarExec-deploy"
}

# Function to configure Git safe directory
configure_git() {
    log "Configuring Git safe directory."
    su - starexec -c "git config --global --add safe.directory /home/starexec/StarExec-deploy"
}

# Function to change ownership of the cloned repository
change_ownership() {
    log "Changing ownership of the repository."
    chown -R tomcat:star-web /home/starexec/StarExec-deploy
}

# Function to create a symbolic link
create_symlink() {
    log "Creating symbolic link."
    su - starexec -c "cd ~/StarExec-deploy/WebContent/css/details && ln -s ../shared"
}

# Clone the repository
clone_repo

# Configure Git and change ownership in parallel
configure_git &
change_ownership &

# Wait for the parallel tasks to complete
wait

# Create the symbolic link
create_symlink

log "Script completed successfully."
