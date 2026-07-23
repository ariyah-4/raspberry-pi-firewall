# Raspberry Pi Firewall & Access Point Gateway

This repository contains the configuration and automation scripts to design and implement a firewall on a Raspberry Pi 4 device. The system utilizes `iptables` as the core firewall application and configures the Raspberry Pi to act as a dual-band wireless access point.

## Network Architecture
The firewall is configured with three distinct network interfaces:
* **`eth0`**: Connected to a Class A network, providing internet connectivity to the Raspberry Pi via an Ethernet cable.
* **`wlan0`**: Operates on the 5GHz band and acts as a Class B access point for end devices to connect and route data through the firewall.
* **`wlan1`**: Operates on the 2.4GHz band and acts as a Class C access point for end devices to connect and route data through the firewall.

## Hardware & Software Requirements
* **Device**: Raspberry Pi 4.
* **Operating System**: Raspberry Pi OS (64-bit), a port of Debian Trixie.
* **Additional Hardware**: TP-Link Wireless Dongle (requires manual driver installation of `rtw88` via git clone).
* **Core Packages**: `iptables` (firewall application), `hostapd` (access point management), and `dnsmasq` (DHCP server).

## Core Automation Scripts
* **`start_project.sh`**: The primary automation script used to run the entire project. It handles the boot sequence by performing the following actions:
    * Stops conflicting background services.
    * Wakes up `wlan0` and `wlan1`.
    * Forces class-based IP addresses on `eth0`, `wlan0`, and `wlan1`.
    * Disables power save mode on `wlan1` (the TP-Link dongle).
    * Restarts `dnsmasq` to act as the DHCP server.
    * Starts the 5G and 2.4G access points in background mode.
    * Enables the firewall rules by executing the setup script.
* **`firewall_setup.sh`**: A Bash script that configures the `iptables` security rules. It establishes a strict access policy, including a MAC address filter that exclusively allows SSH connections from a single authorized device and denies all other SSH attempts.
* **`disable_firewall.sh`**: A utility script designed to safely disable the firewall on the Raspberry Pi.

## System Configuration Details
* **IP Forwarding**: Packet routing between interfaces is enabled by adding configuration to `/etc/sysctl.d/99-forwarding.conf`.
* **DHCP Management**: The `dhcpcd` service configuration is modified to explicitly ignore `wlan0` and `wlan1`, preventing background interruptions since these interfaces are configured manually.

## Testing & Resource Monitoring
The functionality and stability of the firewall can be verified using the following tools:
* **Security Auditing**: The firewall successfully drops unauthorized packets (such as SSH attempts on port 23), which can be verified in the kernel logs using `sudo dmesg | grep "FIREWALL_DROP"`.
* **Telemetry**: CPU usage under heavy load (such as a `ping` flood) can be tracked using the `sysstat` package.
* **Hardware Diagnostics**: Operating temperatures can be monitored using `vcgencmd measure_temp`, and network speeds from connected clients can be verified using `speedtest-cli`.
