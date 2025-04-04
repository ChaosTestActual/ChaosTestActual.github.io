#!/bin/bash
set -euo pipefail

prefix="RITUAL: BANISH LOGS: "

echo "$prefix __INITIATED__."

echo "$prefix Removing /private/var/log contents..."
sudo rm -rf /private/var/log/*

echo "$prefix Removing /Library/Logs contents..."
sudo rm -rf /Library/Logs/*

echo "$prefix __COMPLETE__."