#!/bin/bash
echo "Starting GCC Compliance Pre-flight Checks..."

# 1. Check if we are in the right directory
if [ ! -d "terraform/environment/dev" ]; then
    echo "ERROR: Terraform directory not found."
    exit 1
fi

# 2. Run Terraform Validate to check syntax
echo "Validating Terraform configuration..."
cd terraform/environment/dev && terraform validate
if [ $? -ne 0 ]; then
    echo "ERROR: Terraform validation failed."
    exit 1
fi

echo "SUCCESS: Pre-flight checks passed."
exit 0