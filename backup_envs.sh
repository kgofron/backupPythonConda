#!/bin/bash

# Conda Environment Backup Script
# This script backs up all conda environments to YAML files

set -e  # Exit on any error

# Configuration
BACKUP_DIR="conda_envs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR_WITH_TIMESTAMP="${BACKUP_DIR}_${TIMESTAMP}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if conda is available
if ! command -v conda &> /dev/null; then
    print_error "conda command not found. Please ensure conda is installed and in your PATH."
    exit 1
fi

# Initialize conda for this shell session
print_status "Initializing conda..."
eval "$(conda shell.bash hook)"

# Create backup directory
if [ ! -d "$BACKUP_DIR_WITH_TIMESTAMP" ]; then
    mkdir -p "$BACKUP_DIR_WITH_TIMESTAMP"
    print_status "Created backup directory: $BACKUP_DIR_WITH_TIMESTAMP"
fi

# Get list of conda environments
print_status "Getting list of conda environments..."
conda env list > "${BACKUP_DIR_WITH_TIMESTAMP}/conda_envs_list.txt"

# Read environments and export them
print_status "Starting environment backup..."
while IFS= read -r line; do
    # Skip header lines and empty lines
    if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*$ ]]; then
        continue
    fi
    
    # Extract environment name (first column)
    env_name=$(echo "$line" | awk '{print $1}')
    
    # Skip if no environment name found
    if [[ -z "$env_name" ]]; then
        continue
    fi
    
    # Skip base environment if it's the current one (can cause issues)
    if [[ "$env_name" == "base" ]]; then
        print_warning "Skipping base environment (exporting base can cause issues)"
        continue
    fi
    
    print_status "Backing up environment: $env_name"
    
    # Export environment to YAML file
    if conda env export -n "$env_name" > "${BACKUP_DIR_WITH_TIMESTAMP}/${env_name}_env.yml" 2>/dev/null; then
        print_status "Successfully backed up: $env_name"
    else
        print_error "Failed to backup environment: $env_name"
    fi
    
done < "${BACKUP_DIR_WITH_TIMESTAMP}/conda_envs_list.txt"

# Create a summary file
print_status "Creating backup summary..."
{
    echo "Conda Environment Backup Summary"
    echo "================================"
    echo "Backup created: $(date)"
    echo "Backup directory: $BACKUP_DIR_WITH_TIMESTAMP"
    echo ""
    echo "Backed up environments:"
    ls -1 "${BACKUP_DIR_WITH_TIMESTAMP}"/*_env.yml 2>/dev/null | sed 's/.*\///' | sed 's/_env\.yml$//' || echo "No environments found"
    echo ""
    echo "To restore an environment, use:"
    echo "conda env create -f <environment_name>_env.yml"
} > "${BACKUP_DIR_WITH_TIMESTAMP}/backup_summary.txt"

print_status "Backup completed successfully!"
print_status "Backup location: $BACKUP_DIR_WITH_TIMESTAMP"
print_status "See backup_summary.txt for details"
