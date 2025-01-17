#!/bin/bash
set -e
set -o pipefail

# THIS SCRIPT RUNS AT DOCKER BUILD TIME AND JUST MAKES THE APP ALONG WITH VOLUMEDATA (DIRECTORY FOR PERSISTENT DATA)

# Function to start MySQL server
start_mysql() {
    echo "Starting MySQL server..."
    /usr/bin/mysqld_safe --basedir=/usr --user=mysql & # --log-error=/var/log/mysql/error.log &
    # Wait for MySQL to start
    until mysqladmin ping &>/dev/null; do
        echo "Waiting for MySQL to start..."
        # cat /var/log/mysql/error.log || true
        sleep 1
    done
    echo "MySQL server started."
}

# Function to start Tomcat server
start_tomcat() {
    echo "Starting Tomcat server..."
    su -c "/project/apache-tomcat-7/bin/catalina.sh run &" tomcat
    echo "Tomcat server started."
}

# Start MySQL and Tomcat servers in parallel
start_mysql &
start_tomcat &

# Wait for both MySQL and Tomcat to start
wait

# Run the Ant build and deploy script
echo "Running Ant build and deploy script..."
bash allScripts/starexecScripts/AntBuildDeploy.sh &
wait

echo "All tasks completed."
