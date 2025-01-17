#!/bin/bash
set -e
set -o pipefail

# Function to create a group if it doesn't already exist
create_group() {
    local group_name=$1
    local group_id=$2
    if ! getent group "$group_name" > /dev/null; then
        sudo groupadd -g "$group_id" "$group_name"
    fi
}

# Function to create a user if it doesn't already exist
create_user() {
    local user_name=$1
    local user_id=$2
    local group_name=$3
    local home_dir=$4
    local comment=$5
    if ! id -u "$user_name" > /dev/null 2>&1; then
        sudo useradd -d "$home_dir" -s /bin/bash -c "$comment" -u "$user_id" -g "$group_name" -m "$user_name"
    fi
}

# Create groups in parallel
create_group "star-web" 160 &
create_group "tomcat" 153 &
create_group "sandbox" 111 &
create_group "sandbox2" 112 &
wait # Wait for all background group creation processes to complete

# Create users in parallel
create_user "tomcat" 153 "star-web" "/home/tomcat" "Tomcat User" &
create_user "starexec" 152 "star-web" "/home/starexec" "Starexec User" &
create_user "sandbox" 111 "sandbox" "/home/sandbox" "Cluster UserOne" &
create_user "sandbox2" 112 "sandbox2" "/home/sandbox2" "Cluster UserTwo" &
wait # Wait for all background user creation processes to complete

# Add sandbox users to star-web group in parallel
sudo usermod -aG star-web sandbox &
sudo usermod -aG star-web sandbox2 &
wait # Wait for all background usermod processes to complete

# Configure Backend.WorkingDir
sudo mkdir -p /export/starexec/sandbox /export/starexec/sandbox2
sudo chown -R tomcat:star-web /export/starexec

# Configure sandbox directories in parallel
for dir in /local/sandbox /local/sandbox2; do
    (
        sudo mkdir -p "$dir"
        sudo chown "$(basename "$dir")":"$(basename "$dir")" "$dir"
        sudo chmod 770 "$dir"
        sudo chmod g+s "$dir"
    ) &
done
wait # Wait for all background directory configuration processes to complete

# Add users to groups in parallel
sudo usermod -aG star-web tomcat &
sudo usermod -aG star-web starexec &
sudo usermod -aG sandbox tomcat &
sudo usermod -aG sandbox2 tomcat &
wait # Wait for all background usermod processes to complete

# Switch to root user
sudo su
