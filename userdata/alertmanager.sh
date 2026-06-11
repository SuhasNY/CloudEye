#!/bin/bash

set -ex

useradd --no-create-home --shell /bin/false alertmanager || true

cd /tmp

wget https://github.com/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-amd64.tar.gz

tar xvf alertmanager-0.28.1.linux-amd64.tar.gz

mkdir -p /etc/alertmanager
mkdir -p /var/lib/alertmanager

cp alertmanager-0.28.1.linux-amd64/alertmanager /usr/local/bin/
cp alertmanager-0.28.1.linux-amd64/amtool /usr/local/bin/

cat > /etc/alertmanager/alertmanager.yml <<EOF
global:
  resolve_timeout: 5m

route:
  receiver: 'null'

receivers:
  - name: 'null'
EOF

cat > /etc/systemd/system/alertmanager.service <<EOF
[Unit]
Description=Alertmanager
After=network.target

[Service]
Type=simple
User=alertmanager
Group=alertmanager

ExecStart=/usr/local/bin/alertmanager \
  --config.file=/etc/alertmanager/alertmanager.yml \
  --storage.path=/var/lib/alertmanager

Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable alertmanager
systemctl start alertmanager