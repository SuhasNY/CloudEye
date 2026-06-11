#!/bin/bash

set -ex

apt-get update -y

apt-get install -y software-properties-common

wget -q -O - https://packages.grafana.com/gpg.key | gpg --dearmor -o /usr/share/keyrings/grafana.gpg

echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" > /etc/apt/sources.list.d/grafana.list

apt-get update -y

apt-get install grafana -y

systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server