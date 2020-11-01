#!/bin/sh

echo "Stopping Companion"
systemctl stop companion
read -p "Companion Stopped" -t 3

echo "Pulling updated Companion codebase for v2.1.0"
cd /usr/local/src/companion
git remote update origin --prune
git fetch
git checkout v2.1.0
read -p "Companion v2.1.0 codebase pulled" -t 3

echo "Updating Companion Core"
yarn update
read -p "Companion Core Update complete" -t 3

echo "Pulling updated supplemental CompanionPi repository"
# If CompanionPi isn't already cloned, clone it
# If not, navigate to the directory and pull latest
if [[ ! -f "/usr/local/src/CompanionPi"]]; then
    cd /usr/local/src
    git clone https://github.com/jarodwsams/CompanionPi.git
else
    cd /usr/local/src/CompanionPi
    git remote update origin --prune
    git pull
fi
# Remove the companionpi-install script as that's only used for initial installation
if [[ -f "companionpi-install.sh"]]; then
    rm companionpi-install.sh
fi
read -p "CompanionPi repository pulled" -t 3


echo "Checking udev rules and systemd unit file"
# Check for udev rules file
if [[ -f "/etc/systemd/system/companion.service"]]; then
    # file exists
    if cmp -s "udev-rules/50-companion.rules" "/etc/udev/rules.d/50-companion.rules"; then
        echo "udev rules are up-to-date"
    fi
else
    # file does not exist
    echo "udev rules file is missing or incorrect"
    cp udev-rules/50-companion.rules /etc/udev/rules.d/50-companion.rules
fi
# Check for companion.service Systemd unit file
if [[ -f "/etc/systemd/system/companion.service"]]; then
    # file exists
    if cmp -s "systemd-service/companion.service" "/etc/systemd/system/companion.service"; then
        echo "systemd unit file is up-to-date"
    fi
else
    # file does not exist
    echo "Systemd unit file missing or incorrect. Copying latest from repo."
    cp systemd-service/companion.service /etc/systemd/system/companion.service
fi

# Check for companion-update symlink
if [[ -f "/usr/local/bin/companion-update"]]; then
    # symlink for companion-update already exists
else
    ln -s /usr/local/src/CompanionPi/companionpi-update.sh /usr/local/bin/companion-update
    chmod +x /usr/local/bin/companion-update
fi

read -p "Finishing up..." -t 3

read -p "Rebooting in 5 seconds..." -t 5
reboot
