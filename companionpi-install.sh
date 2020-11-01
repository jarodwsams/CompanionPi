#!/bin/bash

echo "Installing dependencies"
apt update && sudo apt upgrade -y && sudo apt autoclean -y && sudo apt autoremove
apt install libgusb-dev npm nodejs git build-essential cmake libudev-dev libusb-1.0-0-dev -y
read -p "Dependencies installed" -t 5

echo "Installing Node.js and Yarn"
npm install n yarn -g
n 8.12.0
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
read -p "Node.js and Yarn installation complete" -t 5

echo "Installing Companion"
cd /usr/local/src
git clone https://github.com/bitfocus/companion.git
cd companion
git checkout v2.1.0
yarn update
./tools/build_writefile.sh
read -p "Companion installation complete" -t 5

echo "Pulling updated supplemental CompanionPi repository"
cd /usr/local/src
git clone https://github.com/jarodwsams/CompanionPi.git
read -p "CompanionPi repository pulled" -t 5

echo "Checking udev rules and systemd unit file"
if [[ -f "/etc/systemd/system/companion.service"]]; then
    if cmp -s "udev-rules/50-companion.rules" "/etc/udev/rules.d/50-companion.rules"; then
        echo "udev rules are up-to-date"
    fi
else
    echo "udev rules file is up-to-date"
    cp udev-rules/50-companion.rules /etc/udev/rules.d/50-companion.rules
fi
if [[ -f "/etc/systemd/system/companion.service"]]; then
    if cmp -s "systemd-service/companion.service" "/etc/systemd/system/companion.service"; then
        echo "systemd unit file is up-to-date"
    fi
else
    echo "Systemd unit file missing or incorrect. Copying latest from repo."
    cp systemd-service/companion.service /etc/systemd/system/companion.service
fi
read -p "Finishing up..." -t 5

ln -s /usr/local/src/CompanionPi/companionpi-update.sh /usr/local/bin/companion-update
chmod +x /usr/local/bin/companion-update

read -p "Rebooting in 5 seconds..." -t 5
reboot
