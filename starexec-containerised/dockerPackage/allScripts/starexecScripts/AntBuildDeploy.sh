#!/bin/bash
set -e
set -o pipefail

# Function to initialize the database
initialize_database() {
	sudo mysql -u root <<EOF
DROP DATABASE IF EXISTS starexec;
CREATE DATABASE starexec;
GRANT ALL PRIVILEGES ON starexec.* TO 'se_admin'@'localhost' IDENTIFIED BY 'dfsdf34RFerfg3TFGRfrF3edFVg12few2';
FLUSH PRIVILEGES;
EOF
}

# Function to run ant build
run_ant_build() {
	local buildfile="build.xml"
	local targets="reload-sql update-sql"
	if ant build -buildfile "$buildfile" $targets; then
		echo "Ant build succeeded."
	else
		echo "Ant build failed. Attempting to run NewInstall.sql..."
		cd ~starexec/StarExec-deploy/sql
		mysql -u root starexec < NewInstall.sql
		cd ~starexec/StarExec-deploy
		if ant build -buildfile "$buildfile" $targets; then
			echo "Ant build succeeded after running NewInstall.sql."
		else
			echo "ERROR! Please rerun docker build..."
			exit 1
		fi
	fi
}

# Main script execution
main() {
	# Initialize the database in the background
	initialize_database &

	# Wait for the database initialization to complete
	wait

	# Change directory to the deployment directory
	cd ~starexec/StarExec-deploy

	# Run ant build in the background
	echo "Running ant build -buildfile build.xml reload-sql update-sql"
	run_ant_build &
	
	# Wait for the ant build to complete
	wait
}

# Execute the main function
main
