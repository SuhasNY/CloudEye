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

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
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