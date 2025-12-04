## Self-Healing Infrastructure using Prometheus, Alertmanager, Webhook & Ansible
Automatically detect service failures and auto-recover using monitoring + automation.

# 📌 Overview
This project implements a Self-Healing Infrastructure where:
- Prometheus monitors system & service health
- Alertmanager triggers alerts when NGINX goes down
- Webhook receives alert data
- Ansible Playbook automatically restarts the failed service
This creates a fully automated auto-recovery mechanism.

## ⚙️ Tools Used

- Prometheus (Monitoring)
- Node Exporter (Host metrics)
- nginx 
- Alertmanager (Alert Delivery)
- Flask Webhook (Python)
- Ansible (Auto-Healing)
- Shell Scripts (Automation)

# 📁 Project Structure
```
self-healing-infra/
├── alertmanager  
│   ├── alertmanager.yml  
│   └── start-alertmanager.sh  
│  
├── ansible  
│   └── heal.yml  
│  
├── prometheus  
│   ├── prometheus.yml  
│   ├── rules.yml  
│   └── start-prometheus.sh  
│  
├── README.md  
│  
└── webhook  
    ├── start-webhook.sh  
    ├── webhook.log  
    └── webhook.py  
```
file `prometheus.yml`
```
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'nginx-service'
    static_configs:
      - targets: ['localhost:80']
rule_files:
  - "rules.yml"

```
file `rulse.yml`
```
groups:
- name: service-alerts
  rules:
  - alert: NginxDown
    expr: up{job="nginx-service"} == 0
    for: 15s
    labels:
      severity: critical
    annotations:
      description: "NGINX service is down."

  - alert: HighCPU
    expr: node_cpu_seconds_total{mode="idle"} < 0.1
    for: 30s
    labels:
      severity: warning
    annotations:
      description: "CPU usage is above 90%."
```
file `start-prometheus.sh`
```
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

```
# Start Prometheus
```
bash /opt/self-healing-infra/prometheus/start-prometheus.sh
```
# 🔄 Verify Service Are Running
Prometheus
```
ss -tulnp | grep 9090
```
file `alertmanager.yml`
```
route:
  receiver: 'ansible-webhook'

receivers:
  - name: 'ansible-webhook'
    webhook_configs:
      - url: 'http://localhost:5001/webhook'

```
file `start-alertmanager.sh `
```
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

```
# Start Alertmanager
```
bash /opt/self-healing-infra/alertmanager/start-alertmanager.sh
```
# 🔄 Verify Service Are Running
Alertmanager
```
ss -tulnp | grep 9093
```
file `webhook.py`
```
from flask import Flask, request
import os

app = Flask(__name__)

@app.route("/webhook", methods=['POST'])
def webhook():
    data = request.json
    os.system("ansible-playbook /opt/playbooks/heal.yml")
    return "OK", 200

app.run(host="0.0.0.0", port=5001)

```
file ` start-webhook.sh`
```
#!/bin/bash

echo "Starting Webhook Server..."

SCRIPT="/opt/self-healing-infra/webhook/webhook.py"

python3 $SCRIPT > /opt/self-healing-infra/webhook/webhook.log 2>&1 &

echo "Webhook started. Logs: webhook.log"

```
# Start Webhook
```
bash /opt/self-healing-infra/webhook/start-webhook.sh
```
# 🔄 Verify Service Are Running
Webhook
```
ss -tulnp | grep 5001
```
file `heal.yml`
```
---
- name: Auto-Healing Playbook
  hosts: localhost
  become: yes

  tasks:
    - name: Restart NGINX service
      service:
        name: nginx
        state: restarted
```
# run ansible playbook
```
ansible-playbook /opt/self-healing-infra/ansible/heal.yml
```
## 🧪 Testing the Auto-Healing (Demo)
### Step 1 — Stop NGINX manually:
```
sudo systemctl stop nginx
```
### Step 2 — Prometheus detects:  
`**"NGINX service down"**`
### Step 3 — Alertmanager triggers webhook → runs Ansible.
### Step 4 — Ansible heals service:

NGINX automatically starts again 🎉

## ✅ Conclusion

This project demonstrates a complete **Self-Healing Infrastructure** using:

- Prometheus  
- Alertmanager  
- Webhook  
- Ansible  

If any service fails → It automatically recovers without human intervention.
