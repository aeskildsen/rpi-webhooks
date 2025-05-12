#!/bin/bash

if [ $EUID -ne 0 ]; then
    echo 'This script must be run as root. Please use sudo or log in as root.'
    exit 1
fi

systemctl stop webhooks.service
systemctl disable webhooks.service
rm -f /etc/systemd/system/webhooks.service
systemctl daemon-reload

rm -rf /opt/rpi-webhooks
rm -rf /etc/opt/rpi-webhooks
rm -f /var/log/rpi-webhooks-install.log
