#!/bin/bash
set -e
set -o pipefail

# Create the directory in the background
sudo mkdir -p /scratch/projects/exempt/starexec/data_dir &

# Change ownership of the directory in the background
sudo chown tomcat:star-web /scratch/projects/exempt/starexec/data_dir &

# Wait for the background processes to complete
wait

# Create symbolic links
sudo ln -s /scratch/projects/exempt/starexec /starexec &
sudo ln -s /scratch/projects/exempt/starexec/data_dir /home/starexec &

# Wait for the symbolic links to be created
wait

# Append to the export file
sudo echo "/export10.10.1.0/24(rw,no_root_squash,sync,no_subtree_check)" >> /etc/exp

# Re-export the file systems
exportfs -ra

echo "done"
