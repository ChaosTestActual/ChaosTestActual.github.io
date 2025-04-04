#!/bin/bash
set -euo pipefail

prefix="RITUAL: IDENTITY RECOHERENCE: "

echo "$prefix __INITIATED__."

# Step 1: Install prerequisites
sh ./identity-recoherence/ritual__install-prereqs.sh

# Step 2: Configure system
sh ./identity-recoherence/ritual__configure-system.sh

# Step 3: Generate GPG key (for code signing + SSH)
sh ./identity-recoherence/ritual__generate-gpg-key.sh

# Step 5: Provision one or more YubiKeys
while true; do
  read -rp "$prefix Insert a YubiKey and press ENTER to continue." _
  sh ./identity-recoherence/ritual__provision-key.sh

  read -rp "$prefix Provision another YubiKey? [Y]es / [N]o: " response
  if [[ "$response" =~ ^[Nn] ]]; then
    break
  fi
done

# Step 6: Finalize
sh ./identity-recoherence/ritual__finalize.sh

echo "$prefix __COMPLETE__."