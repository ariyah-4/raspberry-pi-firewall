#!/bin/bash

echo "--- [ STARTING FIREWALL PROJECT ] ---"

# 1. Kill potential conflicts
echo " [!] Stopping conflicting services..."
sudo systemctl stop wpa_supplicant
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
sudo systemctl stop NetworkManager

sudo killall -9 hostapd 2>/dev/null
sudo killall -9 wpa_supplicant 2>/dev/null
sudo killall -9 wpa_cli 2>/dev/null

sleep 3

# 2. Wake up interfaces & FORCE IP ADDRESSES
echo " [!] Waking up network cards and forcing IPs..."
sudo ip link set wlan0 up
sudo ip link set wlan1 up

# Force the IP assignment manually
sudo ip addr add 10.10.10.100/8 dev eth0      # Class A
sudo ip addr add 172.16.1.1/16 dev wlan0      # Class B (5G)
sudo ip addr add 192.168.1.1/24 dev wlan1     # Class C (2G)

# Disable power save to prevent drops
sudo iw dev wlan1 set power_save off

sleep 2

# 4. Restart DHCP Server
echo " [!] Restarting DHCP (dnsmasq)..."
sudo systemctl restart dnsmasq

# 3. Start Access Points (Background Mode)
echo " [!] Starting 5G Access Point (wlan0)..."
sudo hostapd -B /etc/hostapd/hostapd-5g.conf
sleep 5

echo " [!] Starting 2G Access Point (wlan1)..."
sudo hostapd -B /etc/hostapd/hostapd-2g.conf
sleep 5

# 5. Enable Firewall Rules
echo " [!] Applying Firewall Rules..."
~/firewall_setup.sh

echo "--- [ SYSTEM READY ] ---"
