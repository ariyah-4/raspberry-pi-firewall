#!/bin/bash

# --- 1. Flush Existing Rules (Start Fresh) ---
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X

# --- 2. Default Policy: DENY All [cite: 112] ---
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# --- 3. Allow Loopback (Localhost) ---
sudo iptables -A INPUT -i lo -j ACCEPT

# --- 4. Anti-IP Spoofing [cite: 117] ---
# Block private IP ranges arriving on the Public Internet interface (eth0)
sudo iptables -A INPUT -i eth0 -s 172.16.0.0/16 -j DROP
sudo iptables -A INPUT -i eth0 -s 192.168.0.0/16 -j DROP

# --- 5. State Management (Allow Return Traffic) [cite: 116] ---
# Allow replies to connections we started
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# --- 6. Enable NAT (Internet Sharing) [cite: 115] ---
# Masquerade traffic going out of eth0
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# --- 7. Internal Routing (Forwarding) ---
# Allow 5G (wlan0) <--> 2G (wlan1) [cite: 114]
sudo iptables -A FORWARD -i wlan0 -o wlan1 -j ACCEPT
sudo iptables -A FORWARD -i wlan1 -o wlan0 -j ACCEPT

# Allow Local LANs -> Internet [cite: 115]
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
sudo iptables -A FORWARD -i wlan1 -o eth0 -j ACCEPT

# --- 8. Allow Essential Services [cite: 113] ---
# DNS (UDP 53)
sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT
sudo iptables -A FORWARD -p udp --dport 53 -j ACCEPT
# DHCP (UDP 67/68)
sudo iptables -A INPUT -p udp --dport 67:68 -j ACCEPT
# ICMP (Ping)
sudo iptables -A INPUT -p icmp -j ACCEPT
sudo iptables -A FORWARD -p icmp -j ACCEPT

# --- 9. Management Access (SSH & RDP) [cite: 117] ---
# ALLOW only from Internal Interfaces (wlan0, wlan1)
sudo iptables -A INPUT -i wlan0 -p tcp -m multiport --dports 22,3389 -m mac --mac-source <YOUR_MAC_ADDRESS_HERE> -j ACCEPT
sudo iptables -A INPUT -i wlan1 -p tcp -m multiport --dports 22,3389 -m mac --mac-source <YOUR_MAC_ADDRESS_HERE> -j ACCEPT

# --- 10. Explicitly Deny VNC [cite: 117] ---
# Log it first, then drop it (Good for Evidence)
sudo iptables -A INPUT -p tcp --dport 5900 -j LOG --log-prefix " **VNC_ATTEMPT**: "
sudo iptables -A INPUT -p tcp --dport 5900 -j DROP

# --- 11. Log All Dropped Packets [cite: 119] ---
# Must be the last rule
sudo iptables -A INPUT -j LOG --log-prefix " **FIREWALL_DROP**: "
