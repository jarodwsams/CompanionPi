ECHO "Stopping Companion"
systemctl stop companion
ECHO "Companion Stopped"

ECHO "Pulling updated Companion codebase for v2.1.0"
cd /usr/local/bin/companion
git remote update origin --prune
git fetch
git checkout v2.1.0
git merge
ECHO "Companion v2.1.0 codebase pulled"

ECHO "Updating Companion Core"
yarn update
ECHO "Companion Core Update complete"

ECHO "Pulling updated supplemental CompanionPi repository"
cd /usr/local/bin/companionpi
git remote update origin --prune
git fetch
git checkout v2.1.0
git merge
ECHO "CompanionPi repository pulled"


read -p "Rebooting in 5 seconds..." -t 5
reboot