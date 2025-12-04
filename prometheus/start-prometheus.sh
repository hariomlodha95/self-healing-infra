#!/bin/bash

echo "Starting Prometheus..."

# Prometheus binary path in /opt
PROM_PATH="/opt/prometheus/prometheus"

# Prometheus config path
CONFIG_PATH="/opt/self-healing-infra/prometheus/prometheus.yml"

# Run Prometheus
$PROM_PATH \
  --config.file=$CONFIG_PATH \
  --web.enable-lifecycle \
  --storage.tsdb.path="/opt/prometheus/data" \
  --storage.tsdb.retention.time=15d > /opt/prometheus/prometheus.log 2>&1 &

echo "Prometheus started. Logs: /opt/prometheus/prometheus.log"

