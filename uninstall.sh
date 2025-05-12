#!/bin/bash

if [ $EUID -ne 0 ]; then
    echo 'This script must be run as root. Please use sudo or log in as root.'
    exit 1
fi

systemctl stop webhooks.service
systemctl disable webhooks.service

rm -rf /opt/rpi-webhooks
rm -rf /etc/opt/rpi-webhooks
rm -f /etc/systemd/system/webhooks.service
rm -f /var/log/rpi-webhooks-install.log
