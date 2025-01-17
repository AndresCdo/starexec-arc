#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e
# Exit if any command in a pipeline fails
set -o pipefail

# Define the target file path
TARGET_FILE=~starexec/StarExec-deploy/build/overrides.properties
SOURCE_FILE=allScripts/starexecScripts/overridesproperties.properties

# Use a single sudo call to create and write to the target file
# This reduces the overhead of multiple sudo calls
sudo bash -c "touch $TARGET_FILE && cat $SOURCE_FILE >> $TARGET_FILE"

# Print a message indicating the completion of the script
echo "Done making overrides.properties file"
