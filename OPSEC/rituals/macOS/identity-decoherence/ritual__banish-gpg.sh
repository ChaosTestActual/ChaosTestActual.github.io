#!/bin/bash
set -euo pipefail

prefix="RITUAL: BANISH GPG: "

echo "$prefix __INITIATED__."

# Cleanse it with fire: removes all GPG keys and configuration
if [ -d ~/.gnupg ]; then
  echo "$prefix found ~/.gnupg, purging..."
  rm -rf ~/.gnupg
else
  echo "$prefix no ~/.gnupg found — already clean."
fi

echo '$prefix All GPG keys and configuration have been purged.
$prefix __COMPLETE__.'
