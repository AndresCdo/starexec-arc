#!/bin/bash
set -e
set -o pipefail

# Function to download and extract Tomcat
download_and_extract_tomcat() {
    local version=$1
    local url="https://archive.apache.org/dist/tomcat/tomcat-7/v${version}/bin/apache-tomcat-${version}.tar.gz"
    wget ${url}
    sudo tar --no-same-permissions --no-same-owner -xzvf apache-tomcat-${version}.tar.gz
}

# Function to download MySQL connector
download_mysql_connector() {
    local version=$1
    local url="https://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/${version}/mysql-connector-java-${version}.jar"
    wget -O mysql-connector-java-${version}.jar ${url}
}

echo "Creating directory for project"
sudo mkdir -p /project
cd /project

# Unzipping Tomcat 7 from StarExec repo clone (to extract libs)
echo "Unzipping Tomcat 7 from StarExec repo clone (to extract libs)"
sudo unzip ~starexec/StarExec-deploy/distribution/apache-tomcat-7.0.64.zip &
unzip_pid=$!

# Downloading and setting up newer Tomcat version
echo "Downloading and setting up latest version of Tomcat 7"
TOMCAT_VERSION=7.0.94
download_and_extract_tomcat ${TOMCAT_VERSION} &
download_tomcat_pid=$!

# Downloading MySQL connector
MYSQL_CON_VERSION=5.1.9
download_mysql_connector ${MYSQL_CON_VERSION} &
download_mysql_pid=$!

# Wait for all background processes to complete
wait $unzip_pid
echo "Done unzipping"

wait $download_tomcat_pid
echo "Done downloading and extracting Tomcat ${TOMCAT_VERSION}"

wait $download_mysql_pid
echo "Done downloading MySQL connector"

# Copying necessary libraries from the old Tomcat to the new one
sudo cp /project/apache-tomcat-7.0.64/lib/drmaa.jar /project/apache-tomcat-${TOMCAT_VERSION}/lib/
sudo cp mysql-connector-java-${MYSQL_CON_VERSION}.jar /project/apache-tomcat-${TOMCAT_VERSION}/lib

# Creating symbolic link for Tomcat
ln -s /project/apache-tomcat-${TOMCAT_VERSION} /project/apache-tomcat-7
sudo chown -R tomcat:tomcat /project/apache-tomcat-${TOMCAT_VERSION}
chmod 744 /project/apache-tomcat-7/bin/*.sh
echo "Done setting up Tomcat ${TOMCAT_VERSION}"

# Creating Tomcat 7 startup script
echo "Creating Tomcat 7 startup script"
sudo tee /etc/systemd/system/tomcat7.service > /dev/null <<EOF
[Unit]
Description=StarExec Apache Tomcat 7 Servlet Container
After=syslog.target network.target

[Service]
User=tomcat
Group=tomcat
Type=forking
Environment=CATALINA_PID=/var/run/tomcat-7.pid
Environment=CATALINA_HOME=/project/apache-tomcat-7
Environment=CATALINA_BASE=/project/apache-tomcat-7
ExecStart=/project/apache-tomcat-7/bin/startup.sh
ExecStop=/project/apache-tomcat-7/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Creating Tomcat 7 setenv.sh
echo "Creating Tomcat 7 setenv.sh"
sudo tee /project/apache-tomcat-7/bin/setenv.sh > /dev/null < /allScripts/starexecScripts/setenv.txt
sudo chown tomcat:tomcat /project/apache-tomcat-7/bin/setenv.sh
echo "Done creating setenv.sh"
echo "Done configuring Tomcat 7"
