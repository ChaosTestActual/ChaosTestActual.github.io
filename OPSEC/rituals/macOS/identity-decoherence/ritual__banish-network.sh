#!/bin/bash
set -euo pipefail

prefix="RITUAL: BANISH NETWORK: "

echo "$prefix __INITIATED__."

echo "$prefix Removing preferred Wi-Fi networks..."
networksetup -removeallpreferredwirelessnetworks en0 || echo "$prefix Interface en0 not found or already banished."

echo "$prefix Flushing DNS cache..."
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

echo "$prefix __COMPLETE__."