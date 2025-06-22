#!/bin/bash

# Test script for conda environment backup
# This script creates a test conda environment and then tests the backup

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if conda is available
if ! command -v conda &> /dev/null; then
    print_error "conda command not found. Cannot run test."
    exit 1
fi

# Initialize conda
eval "$(conda shell.bash hook)"

TEST_ENV_NAME="test_backup_env_$(date +%s)"

print_status "Creating test environment: $TEST_ENV_NAME"

# Create a test environment with some packages
conda create -n "$TEST_ENV_NAME" python=3.9 numpy pandas -y

print_status "Test environment created successfully"

# Run the backup script
print_status "Running backup script..."
./backup_envs.sh

# Check if backup was created
BACKUP_DIRS=$(ls -d conda_envs_* 2>/dev/null | tail -1)
if [ -n "$BACKUP_DIRS" ]; then
    print_status "Backup directory found: $BACKUP_DIRS"
    
    # Check if our test environment was backed up
    if [ -f "$BACKUP_DIRS/${TEST_ENV_NAME}_env.yml" ]; then
        print_status "✓ Test environment backup file found"
    else
        print_error "✗ Test environment backup file not found"
    fi
    
    # Check if summary file exists
    if [ -f "$BACKUP_DIRS/backup_summary.txt" ]; then
        print_status "✓ Backup summary file created"
    else
        print_error "✗ Backup summary file not found"
    fi
    
    # Display backup contents
    print_status "Backup contents:"
    ls -la "$BACKUP_DIRS"
    
else
    print_error "No backup directory found"
fi

# Clean up test environment
print_status "Cleaning up test environment..."
conda env remove -n "$TEST_ENV_NAME" -y

print_status "Test completed!" 