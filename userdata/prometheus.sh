#!/bin/bash

set -ex

apt update -y

# Create Prometheus user
useradd --no-create-home --shell /bin/false prometheus || true

# Download Prometheus
cd /tmp

wget https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz

tar xvf prometheus-3.5.0.linux-amd64.tar.gz

# Create required directories
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus

# Install binaries
cp prometheus-3.5.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-3.5.0.linux-amd64/promtool /usr/local/bin/

# Set permissions
chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /var/lib/prometheus

# Create Prometheus configuration
cat > /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s

rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - '172.31.9.250:9093'

scrape_configs:
  - job_name: 'prometheus'

    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'

    static_configs:
      - targets: ['172.31.1.189:9100']

EOF

cat > /etc/prometheus/alerts.yml <<EOF
groups:
  - name: cloudeye-alerts

    rules:
      - alert: NodeExporterDown
        expr: up{job="node_exporter"} == 0
        for: 1m

        labels:
          severity: critical

        annotations:
          summary: "Node Exporter is down"
          description: "Prometheus cannot reach Node Exporter"
EOF

# Create systemd service
cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
After=network.target

[Service]
Type=simple
User=prometheus
Group=prometheus

ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start Prometheus
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus