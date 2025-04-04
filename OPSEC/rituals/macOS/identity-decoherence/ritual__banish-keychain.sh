#!/bin/bash
set -euo pipefail

prefix="RITUAL: BANISH KEYCHAIN: "

echo "$prefix __INITIATED__."

echo "$prefix Deleting login.keychain-db..."
security delete-keychain login.keychain-db || echo "$prefix Keychain not found or already banished."

echo "$prefix Deleting system keychains..."
sudo rm -rf /Library/Keychains/*
sudo rm -rf /System/Library/Keychains/*

echo "$prefix __COMPLETE__."