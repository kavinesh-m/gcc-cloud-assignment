#!/bin/bash
ALB_URL=$1

if [ -z "$ALB_URL" ]; then
    echo "ERROR: No ALB URL provided. Orchestration failed."
    exit 1
fi

echo "Starting Post-deployment Verification for: $ALB_URL"

# Logic Breakdown:
# -L: Follow the HTTP (80) -> HTTPS (443) redirect
# -k: Ignore the "Insecure" SSL certificate warning 
# --retry 6: Give ECS Fargate ~3 minutes to stabilize
# --retry-delay 30: Wait 30 seconds between pings

if curl -s -L -k -f --retry 6 --retry-delay 30 "$ALB_URL" > /dev/null; then
    echo "----------------------------------------------------"
    echo "SUCCESS: Application is live and accessible!"
    echo "URL: $ALB_URL"
    echo "----------------------------------------------------"
    exit 0
else
    echo "ERROR: Application health check failed after multiple attempts."
    exit 1
fi