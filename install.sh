#!/bin/bash

# Check for superuser privileges
if [ $EUID -ne 0 ]; then
    echo 'This script must be run as root. Please use sudo or log in as root.'
    exit 1
fi

# Redirect command output to a log file
LOGFILE="/var/log/rpi-webhooks-install.log"

echo "--- rpi-webhooks install script started at: $(date) ---" >> "$LOGFILE"

hint_log() {
    echo "See log file at $LOGFILE"
}

# Install the Python dependencies
echo 'Installing Python dependencies...'
apt-get update >> "$LOGFILE" 2>&1
if [ $? -ne 0]; then
    apt-get install -y python3-yaml python3-flask >> "$LOGFILE" 2>&1
fi

if [ $? -ne 0 ]; then
    echo 'Failed to install Python dependencies, aborting.'
    hint_log
    echo "--- rpi-webhooks installation failed at: $(date) ---" >> "$LOGFILE"
    exit 2
fi

# Install files
echo 'Installing files...'
mkdir -p /opt/rpi-webhooks /etc/opt/rpi-webhooks >> "$LOGFILE" 2>&1
cp ./api.py /opt/rpi-webhooks >> "$LOGFILE" 2>&1
cp ./routes.yaml /etc/opt/rpi-webhooks >> "$LOGFILE" 2>&1
cp ./webhooks.service /etc/systemd/system/webhooks.service >> "$LOGFILE" 2>&1

# Enable and start the API as a systemd service
echo 'Enabling and starting the API as a systemd service...'
systemctl daemon-reload >> "$LOGFILE" 2>&1
systemctl enable webhooks.service >> "$LOGFILE" 2>&1 && systemctl start webhooks.service >> "$LOGFILE" 2>&1

if [ $? -ne 0 ]; then
    echo 'Failed to enable API as a systemd service.'
    hint_log
    exit 3
fi

echo "--- rpi-webhooks installation finished at: $(date) ---" >> "$LOGFILE"
echo "" >> "$LOGFILE"

echo 'Installation successful.'
echo 'Check webhook daemon status with "systemctl status webhooks.service"'
echo 'To call API functions, make a POST request, e.g. "curl -X POST http://<ip-address>:5000/reboot"'
echo 'To change or create more webhooks, edit routes.yaml and restart the service with "sudo systemctl restart webhooks.service" to apply the changes.'
echo 'To uninstall, run uninstall.sh.'

exit 0