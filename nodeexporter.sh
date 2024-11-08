#!/bin/bash

# Remove any existing attempts to download or install
echo "Removing existing Node Exporter files..."
sudo rm -f /usr/local/bin/node_exporter
sudo rm -rf /tmp/node_exporter-1.7.0.linux-amd64

# Download Node Exporter
echo "Downloading Node Exporter version 1.7.0..."
curl -L https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz -o /tmp/node_exporter.tar.gz

# Extract the downloaded file
echo "Extracting Node Exporter..."
tar -xvf /tmp/node_exporter.tar.gz -C /tmp

# Move the node_exporter binary to the correct location
echo "Moving Node Exporter binary to /usr/local/bin..."
sudo cp /tmp/node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/

# Set the appropriate ownership and permissions
echo "Setting ownership and permissions..."
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
sudo chmod +x /usr/local/bin/node_exporter

# Create a Node Exporter user
echo "Creating node_exporter user..."
sudo useradd --no-create-home --shell /bin/false node_exporter

# Create systemd service file
echo "Creating systemd service file..."
sudo bash -c 'cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd daemon
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable and start Node Exporter service
echo "Enabling and starting Node Exporter service..."
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Check the status of Node Exporter service
echo "Checking Node Exporter service status..."
sudo systemctl status node_exporter.service

echo "Node Exporter installation and configuration complete!"
