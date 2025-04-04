#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/lib/get_latest_valid_fpr.sh"

prefix="RITUAL: FINALIZE: "

echo "$prefix __INITIATED__."

# Remove temp files
echo "$prefix Removing temporary files..."
rm -f /tmp/cta_selected_key_colors.txt 2>/dev/null || true

# Remove secret key from disk (preserve only on YubiKey)
fpr="$(get_latest_valid_fpr)"

if gpg --list-secret-keys "$fpr" &>/dev/null; then
  echo "$prefix Deleting private key from disk (preserved on YubiKey)..."
  gpg --delete-secret-keys --yes "$fpr"
else
  echo "$prefix No local secret key found for $fpr."
fi

echo "$prefix You may now safely commit and push signed code using your YubiKey."
echo "$prefix __COMPLETE__."