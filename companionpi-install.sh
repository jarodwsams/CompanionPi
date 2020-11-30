#!/bin/bash

echo "Installing dependencies"
apt update && sudo apt upgrade -y && sudo apt autoclean -y && sudo apt autoremove
apt install libgusb-dev npm nodejs git build-essential cmake libudev-dev libusb-1.0-0-dev -y
echo "Dependencies installed"
sleep 3

clear
echo "Installing Node.js and Yarn"
npm install n yarn -g
n 8.12.0
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
echo "Node.js and Yarn installation complete"
sleep 3

clear
echo "Installing Companion v2.1.1"
cd /usr/local/src
git clone https://github.com/bitfocus/companion.git
cd companion
git checkout v2.1.1
yarn update
./tools/build_writefile.sh
echo "Companion installation complete"
sleep 3

clear
echo "Pulling supplemental CompanionPi repository"
cd /usr/local/src
git clone https://github.com/jarodwsams/CompanionPi.git
echo "CompanionPi repository pulled"
sleep 3

clear
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
    sudo systemctl enable systemd-networkd-wait-online.service
fi
echo "Finishing up..."
sleep 3

ln -s /usr/local/src/CompanionPi/companionpi-update.sh /usr/local/bin/companion-update
chmod +x /usr/local/bin/companion-update

clear
echo "Rebooting in 5 seconds..."
sleep 5
reboot
