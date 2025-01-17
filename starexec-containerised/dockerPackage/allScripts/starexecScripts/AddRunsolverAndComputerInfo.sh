#!/bin/bash
set -e
set -o pipefail

# Create directory if it doesn't exist
if [ ! -d /home/starexec/bin ]; then
    mkdir /home/starexec/bin
fi

# Set ownership and permissions
chown tomcat:star-web /home/starexec/bin &
chmod 755 /home/starexec/bin &

# Copy GetComputerInfo script and set permissions
cp ../../solverAdditions/GetComputerInfo /home/starexec/bin &
chown tomcat:star-web /home/starexec/bin/GetComputerInfo &
chmod 755 /home/starexec/bin/GetComputerInfo &

# Wait for all background processes to complete
wait

# Navigate to RunSolverSource directory
cd /home/starexec/StarExec-deploy/src/org/starexec/config/sge/RunSolverSource 

# Clean and build runsolver in parallel
make clean
make -j "$(nproc)"

# Copy the built runsolver to the target directory
cp runsolver /home/starexec/StarExec-deploy/src/org/starexec/config/sge/

# Documentation:
# - The `mkdir` command checks if the directory exists before creating it to avoid redundant operations.
# - The `chown` and `chmod` commands are run in the background to allow parallel execution, improving performance.
# - The `cp` command for GetComputerInfo is also run in the background for parallel execution.
# - The `wait` command ensures that all background processes complete before proceeding.
# - The `make` command uses `-j "$(nproc)"` to utilize all available CPU cores for parallel compilation, speeding up the build process.
# - Removed unnecessary commented-out code to keep the script clean and maintainable.
