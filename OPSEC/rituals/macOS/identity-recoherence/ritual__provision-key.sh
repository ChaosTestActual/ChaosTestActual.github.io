#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/lib/get_latest_valid_fpr.sh"

prefix="RITUAL: PROVISION KEY: "

echo "$prefix __INITIATED__."

echo "$prefix Detecting existing keys on the YubiKey..."
gpg --card-status || {
  echo "$prefix ERROR: No YubiKey detected. Please insert one and try again."
  exit 1
}

read -rp "$prefix Do you want to reset PINs and start fresh? [y/N]: " reset_decision

if [[ "$reset_decision" =~ ^[Yy]$ ]]; then
  echo "$prefix WARNING - Resetting PINs will DELETE existing keys and configuration on the YubiKey."
  read -rp "$prefix Are you absolutely sure? Type 'WIPEIT' to confirm: " confirm_wipe

  if [[ "$confirm_wipe" == "WIPEIT" ]]; then
    echo "$prefix Resetting OpenPGP applet on the YubiKey..."
    gpg --card-edit <<EOF
admin
factory-reset
quit
EOF
    echo "$prefix YubiKey reset complete."
  else
    echo "$prefix Reset canceled. Existing keys will be preserved."
  fi
else
  echo "$prefix Skipping PIN reset. Existing keys will be preserved."
fi

echo "$prefix Importing GPG private key into YubiKey..."

# Extract the fingerprint of the newest non-revoked secret key
fpr="$(get_latest_valid_fpr)"

# Move the subkeys onto the card
gpg --command-fd 0 --status-fd 1 --edit-key "$fpr" <<EOF
toggle
key 1
keytocard
save
EOF

echo "$prefix Provisioning complete."
