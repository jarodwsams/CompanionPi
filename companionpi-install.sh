#!/bin/sh

ECHO "Installing dependencies"
apt update && sudo apt upgrade -y && sudo apt autoclean -y && sudo apt autoremove
apt install libgusb-dev npm nodejs git build-essential cmake libudev-dev libusb-1.0-0-dev -y
ECHO "Dependencies installed"

ECHO "Installing Node.js and Yarn"
npm install n yarn -g
n 8.12.0
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
ECHO "Node.js and Yarn installation complete"

ECHO "Installing Companion"
cd /usr/local/src
git clone https://github.com/bitfocus/companion.git
cd companion
git checkout v2.1.0
yarn update
./tools/build_writefile.sh
ECHO "Companion installation complete"

ECHO "Pulling updated supplemental CompanionPi repository"
cd /usr/local/src
git clone https://github.com/jarodwsams/CompanionPi.git
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
