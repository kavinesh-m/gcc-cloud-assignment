#!/bin/bash
echo "Starting Post-deployment Verification..."

# The URL of your Application Load Balancer from Assignment 1
ALB_URL="https://dev-alb-52149831.ap-southeast-1.elb.amazonaws.com"

echo "Testing connection to: $ALB_URL"

# -f fails on 4xx/5xx errors, -s is silent, -o sends output to /dev/null
if curl -s -f -o /dev/null "$ALB_URL"; then
    echo "SUCCESS: Application is live and healthy!"
    exit 0
else
    echo "ERROR: Application health check failed at $ALB_URL"
    exit 1
fi