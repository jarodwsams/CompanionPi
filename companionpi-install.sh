#!/bin/sh

ECHO "Installing dependencies"
apt update && sudo apt upgrade -y && sudo apt autoclean -y && sudo apt autoremove
apt install libgusb-dev npm nodejs git build-essential cmake libudev-dev libusb-1.0-0-dev -y
ECHO "Dependencies installed"

ECHO "Setting up udev rules"
# Make sure the necessary directory exists. If not, create it.
if [[ ! -f "/etc/udev/rules.d/"]]
then
    mkdir -p /etc/udev/rules.d/
fi
cp udev-rules/50-companion.rules /etc/udev/rules.d/50-companion.rules
udevadm control --reload-rules
ECHO "udev rules updated"

ECHO "Installing Node.js and Yarn"
npm install n yarn -g
n 8.12.0
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
ECHO "Node.js and Yarn installation complete"

ECHO "Installing Companion"
cd /usr/local/bin
git clone https://github.com/bitfocus/companion.git
cd companion
git checkout v2.1.0
yarn update
./tools/build_writefile.sh
ECHO "Companion installation complete"

