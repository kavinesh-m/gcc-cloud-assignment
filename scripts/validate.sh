#!/bin/bash
set -e

echo "Starting GCC Compliance Pre-flight Checks..."

cd terraform/environment/dev

echo "Initializing for validation..."
terraform init -backend=false

echo "Validating Terraform configuration..."
if terraform validate; then
    echo "SUCCESS: Pre-flight checks passed."
    exit 0
else
    echo "ERROR: Terraform validation failed."
    exit 1
fi