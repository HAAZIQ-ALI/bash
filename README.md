# bash
bash script to fix wifi drivers and pacman on arch 
# Arch Linux Network Setup Script

Automated script to fix USB tethering, install NetworkManager, and set up Brave browser on Arch Linux.

## Features
- Updates pacman mirrorlist
- Configures USB tethering automatically
- Installs NetworkManager
- Removes conflicting network manager
- Installs Yay (AUR helper)
- Installs Brave browser

## Usage
```bash
# Download the script
wget https://raw.githubusercontent.com/HAAZIQ-ALI/bash/main/arch.sh
#or
curl -o arch.sh https://raw.githubusercontent.com/HAAZIQ-ALI/bash/main/arch.sh

# Make it executable
chmod +x arch.sh

# Run as root
sudo ./arch.sh
```
