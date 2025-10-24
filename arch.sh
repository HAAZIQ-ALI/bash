#!/bin/bash
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo ./script.sh)"
    exit 1
fi

# Ensure pacman has mirrors
echo 'Updating mirrorlist...'
curl -Lo /etc/pacman.d/mirrorlist https://geo.mirror.pkgbuild.com/mirrorlist/all
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist

# Enable network via USB tethering
echo 'Attempting DHCP on USB tether interface...'
for interface in $(ip link | grep -oP 'enp[0-9s]+u[0-9]+'); do
    echo "Trying interface: $interface"
    ip link set "$interface" up
    dhcpcd "$interface" 2>/dev/null && break || true
done

# Test internet connectivity
if ! ping -c 2 archlinux.org >/dev/null 2>&1; then
    echo "ERROR: No Internet! Check USB tethering is enabled."
    exit 1
fi

echo "Internet connection confirmed!"

# Update package database
pacman -Sy --noconfirm

# Install NetworkManager and dependencies FIRST
echo "Installing NetworkManager..."
pacman -S --noconfirm networkmanager git base-devel

# NOW remove conflicting services (after NetworkManager is installed)
echo "Removing conflicting network managers..."
systemctl stop dhcpcd 2>/dev/null || true
systemctl disable dhcpcd 2>/dev/null || true
systemctl stop netctl 2>/dev/null || true
systemctl disable netctl 2>/dev/null || true
pacman -Rns --noconfirm dhcpcd netctl 2>/dev/null || true

# Enable NetworkManager
systemctl enable NetworkManager
systemctl start NetworkManager

# Unblock wireless
rfkill unblock all

# Install Yay as regular user (if sudo user exists)
SUDO_USER_HOME=$(eval echo ~${SUDO_USER})
if [ -n "$SUDO_USER" ]; then
    echo "Installing yay as $SUDO_USER..."
    cd /tmp
    rm -rf yay
    sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/yay.git
    cd yay
    sudo -u "$SUDO_USER" makepkg -si --noconfirm
    
    # Install Brave browser
    echo "Installing Brave browser..."
    sudo -u "$SUDO_USER" yay -S --noconfirm brave-bin
else
    echo "WARNING: Could not determine non-root user. Skipping yay/brave installation."
fi

echo -e "\n✓ ALL FIXES APPLIED!"
echo "Use 'nmtui' or 'nmcli' to connect to Wi-Fi."
