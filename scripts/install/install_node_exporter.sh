#!/usr/bin/env bash

##############################################################################
#
# Home Lab Setup — Install Node Exporter for Prometheus monitoring
#
##############################################################################

set -e

sudo useradd --no-create-home --shell /bin/false node_exporter || true

cd /tmp

curl -LO https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-1.9.1.linux-arm64.tar.gz

tar xvf node_exporter-1.9.1.linux-arm64.tar.gz

sudo cp node_exporter-1.9.1.linux-arm64/node_exporter /usr/local/bin/

cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
