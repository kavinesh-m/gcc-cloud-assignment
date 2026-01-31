#!/bin/bash
ALB_URL="http://dev-alb-52149831.ap-southeast-1.elb.amazonaws.com"
MAX_RETRIES=5
RETRY_COUNT=0

echo "Starting Post-deployment Verification for: $ALB_URL"

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "Attempting health check ($((RETRY_COUNT+1))/$MAX_RETRIES)..."
    if curl -s -f "$ALB_URL" > /dev/null; then
        echo "SUCCESS: Application is live and healthy!"
        exit 0
    fi
    echo "Application not ready yet. Waiting 60 seconds before next attempt..."
    sleep 60
    RETRY_COUNT=$((RETRY_COUNT+1))
done

echo "ERROR: Application health check failed after $MAX_RETRIES attempts."
exit 1