#!/bin/bash
set -euo pipefail

prefix="RITUAL: GENERATE GPG KEY: "

get_latest_valid_fpr() {
  gpg --list-secret-keys --with-colons "$email" | awk -F: '
    $1 == "sec" && $2 != "r" { t=$5; fpr="" }
    $1 == "fpr" { fpr=$10 }
    fpr && t {
      print t, fpr
      fpr=""; t=""
    }
  ' | sort -nr | head -n1 | cut -d' ' -f2
}

echo "$prefix __INITIATED__."

# Set identity
name="ChaosTestActual"
email="205630590+ChaosTestActual@users.noreply.github.com"
expire="1y"

# Check for existing non-revoked secret key
existing_fpr="$(get_latest_valid_fpr)"

if [[ -n "$existing_fpr" ]]; then
  echo "$prefix A GPG key already exists with fingerprint: $existing_fpr"
  read -rp "$prefix Do you want to reuse this key? [Y/n]: " reuse
  if [[ ! "$reuse" =~ ^[Nn]$ ]]; then
    echo "$prefix Reusing existing key."
    fpr="$existing_fpr"
    echo "$prefix Public key block for GitHub:"
    echo
    gpg --armor --export "$fpr"
    echo
    echo "$prefix Please copy the public key above into GitHub (https://github.com/settings/keys)."
    echo "$prefix When finished, press ENTER to continue."
    read -r
    echo "$prefix __COMPLETE__."
    exit 0
  fi
fi

# Generate a new key
comment="Generated on $(date -u +%Y-%m-%dT%H:%M:%SZ)"
batch_file=$(mktemp)
cat > "$batch_file" <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $name
Name-Comment: $comment
Name-Email: $email
Expire-Date: $expire
%commit
EOF

gpg --batch --generate-key "$batch_file"

# Ensure trustdb is updated before extracting fingerprint
gpg --check-trustdb
sleep 1

rm -f "$batch_file"

# DEBUG: List candidate keys for inspection
echo "$prefix Candidate keys by creation time:"
gpg --list-secret-keys --with-colons | awk -F: '
  $1 == "sec" && $2 != "r" { t=$5; fpr="" }
  $1 == "fpr" { fpr=$10 }
  fpr && t {
    print t, fpr
    fpr=""; t=""
  }
' | sort -nr

# Get the most recently created non-revoked secret key fingerprint
fpr="$(get_latest_valid_fpr)"

echo "$prefix Public key block for GitHub:"
echo
gpg --armor --export "$fpr"
echo
echo "$prefix GPG key generated with fingerprint: $fpr"
echo "$prefix Please copy the public key above into GitHub (https://github.com/settings/keys)."
echo "$prefix When finished, press ENTER to continue."
read -r

echo "$prefix __COMPLETE__."