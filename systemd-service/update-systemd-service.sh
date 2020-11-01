#!/bin/sh

if [[ -f "/etc/systemd/system/companion.service"]]; then
    if cmp -s "systemd-service/companion.service" "/etc/systemd/system/companion.service"; then
        echo "systemd unit file is up-to-date"
    fi
else
    echo "Systemd unit file missing or incorrect. Copying latest from repo."
    cp systemd-service/companion.service /etc/systemd/system/companion.service
fi