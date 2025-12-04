#!/bin/bash

echo "Starting Webhook Server..."

SCRIPT="/opt/self-healing-infra/webhook/webhook.py"

python3 $SCRIPT > /opt/self-healing-infra/webhook/webhook.log 2>&1 &

echo "Webhook started. Logs: webhook.log"


