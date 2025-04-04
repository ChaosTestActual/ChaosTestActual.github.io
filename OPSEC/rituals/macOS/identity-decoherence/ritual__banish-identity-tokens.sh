#!/bin/bash
set -euo pipefail

prefix="RITUAL: BANISH IDENTITY TOKENS: "

echo "$prefix __INITIATED__."

echo "$prefix Deleting identity-related directories..."
rm -rf ~/Library/Accounts
rm -rf ~/Library/IdentityServices
rm -rf ~/Library/Preferences/com.apple.accountsd.plist

echo "$prefix __COMPLETE__."