#!/bin/bash
echo "Waiting for Load Balancer to stabilize (60 seconds)..."

sleep 60

ALB_URL="http://dev-alb-52149831.ap-southeast-1.elb.amazonaws.com"

echo "Starting Post-deployment Verification..."

echo "Testing connection to: $ALB_URL"

if curl -s -f "$ALB_URL" > /dev/null; then
    echo "SUCCESS: Application is live and healthy!"
    exit 0
else
    echo "ERROR: Application health check failed at $ALB_URL"
    exit 1
fi