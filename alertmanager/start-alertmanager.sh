#!/bin/bash

echo "Starting Alertmanager..."

# Alertmanager binary path in /opt
ALERT_PATH="/opt/alertmanager/alertmanager"

# Alertmanager config path
CONFIG_PATH="/opt/self-healing-infra/alertmanager/alertmanager.yml"

$ALERT_PATH \
  --config.file=$CONFIG_PATH \
  --storage.path="/opt/alertmanager/data" > /opt/alertmanager/alertmanager.log 2>&1 &

echo "Alertmanager started. Logs: /opt/alertmanager/alertmanager.log"

