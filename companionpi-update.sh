#!/bin/sh

ECHO "Stopping Companion"
systemctl stop companion
read -p "Companion Stopped" -t 2

ECHO "Pulling updated Companion codebase for v2.1.0"
cd /usr/local/bin/companion
git remote update origin --prune
git fetch
git checkout v2.1.0
read -p "Companion v2.1.0 codebase pulled" -t 2

ECHO "Updating Companion Core"
yarn update
read -p "Companion Core Update complete" -t 2

ECHO "Pulling updated supplemental CompanionPi repository"
# If CompanionPi isn't already cloned, clone it
# If not, navigate to the directory and pull latest
if [[ ! -f "/usr/local/bin/CompanionPi"]]; then
    cd /usr/local/bin
    git clone https://github.com/jarodwsams/CompanionPi.git
else
    cd /usr/local/bin/CompanionPi
    git remote update origin --prune
    git pull
fi
# Remove the companionpi-install script as that's only used for initial installation
if [[ -f "companionpi-install.sh"]]; then
    rm companionpi-install.sh
fi
read -p "CompanionPi repository pulled" -t 5


ECHO "Checking udev rules and systemd unit file"
if [[ -f "/etc/systemd/system/companion.service"]]; then
    if cmp -s "udev-rules/50-companion.rules" "/etc/udev/rules.d/50-companion.rules"; then
        ECHO "udev rules are up-to-date"
    fi
else
    ECHO "udev rules file is up-to-date"
    cp udev-rules/50-companion.rules /etc/udev/rules.d/50-companion.rules
fi
if [[ -f "/etc/systemd/system/companion.service"]]; then
    if cmp -s "systemd-service/companion.service" "/etc/systemd/system/companion.service"; then
        ECHO "systemd unit file is up-to-date"
    fi
else
    ECHO "Systemd unit file missing or incorrect. Copying latest from repo."
    cp systemd-service/companion.service /etc/systemd/system/companion.service
fi
read -p "Finishing up..." -t 5

read -p "Rebooting in 5 seconds..." -t 5
reboot
