#!/bin/bash
# RUNS AT DOCKER RUN TIME AND IS RESPONSIBLE FOR SOFT DEPLOY

set -e
set -o pipefail

# Change ownership and permissions in parallel
{
    chown -R tomcat:star-web /project &
    chown -R tomcat:star-web /home/starexec &
    chown -R tomcat:star-web /home/sandbox &
    chown -R mysql:mysql /var/lib/mysql &
    chmod 755 -R /home/starexec &
    wait # Wait for all background processes to complete
} &

# Start Apache2 server directly
# This assumes Apache2 is correctly configured to run in foreground if necessary
/usr/sbin/apache2ctl -D FOREGROUND &

# Starts MySQL server
# It's already set to run in background with '&'
/usr/bin/mysqld_safe --basedir=/usr --user=mysql &

# try to setup podman remote system connection if it doesn't exist:
{
    echo "Setting up podman connection"
    podman system connection add host-machine-podman-connection \
        ssh://${SSH_USERNAME}@${HOST_MACHINE}:${SSH_PORT}${SOCKET_PATH} \
        --identity=/root/.ssh/starexec_podman_key
} || {
    echo "Failed to setup podman connection"
} &

# Starts Tomcat server
/project/apache-tomcat-7/bin/catalina.sh run &

# Wait for servers to start up
sleep 15

# Perform soft deploy
cd ~starexec/StarExec-deploy
script/soft-deploy.sh && printf "SUCCESS!!! GO IN YOUR BROWSER TO: http://localhost \n\nusername: admin \npassword: admin\n\n"

# Keep the script running indefinitely
sleep infinity
