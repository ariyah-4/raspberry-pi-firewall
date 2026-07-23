#!/bin/bash

echo " [!] Disabling Firewall..."

# 1. Set Default Policies to ACCEPT (Open everything)
# We do this FIRST so we don't lock ourselves out when we flush the rules.
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

# 2. Flush (Delete) all rules from the standard 'filter' table
sudo iptables -F
sudo iptables -X

# 3. Flush (Delete) all rules from the 'nat' table (Removes Masquerading)
sudo iptables -t nat -F
sudo iptables -t nat -X

# 4. Flush (Delete) all rules from the 'mangle' table
sudo iptables -t mangle -F
sudo iptables -t mangle -X

# 5. Verification
echo " [✓] Firewall Disabled. Current Status:"
sudo iptables -L | grep "Chain"
