#!/bin/bash
ALB_URL=$1
EXPECTED_TEXT="Fail-Rollback-Test-String" 

if [ -z "$ALB_URL" ]; then
    echo "ERROR: No ALB URL provided."
    exit 1
fi

echo "Starting Post-deployment Verification for: $ALB_URL"

MAX_RETRIES=6
COUNT=0

while [ $COUNT -lt $MAX_RETRIES ]; do
    echo "Attempting to verify content (Attempt $((COUNT+1))/$MAX_RETRIES)..."
    
    RESPONSE=$(curl -s -L -k "$ALB_URL")
    
    if echo "$RESPONSE" | grep -q "$EXPECTED_TEXT"; then
        echo "----------------------------------------------------"
        echo "SUCCESS: Found expected text '$EXPECTED_TEXT'!"
        echo "URL: $ALB_URL"
        echo "----------------------------------------------------"
        exit 0
    fi
    
    echo "Expected text not found yet. Waiting 30 seconds..."
    sleep 30
    COUNT=$((COUNT+1))
done

echo "ERROR: Content verification failed after $MAX_RETRIES attempts."
exit 1