#!/bin/bash
set -euo pipefail

prefix="RITUAL: BANISH SSH: "

echo "$prefix __INITIATED__."

echo "$prefix Deleting ~/.ssh directory..."
rm -rf ~/.ssh

echo "$prefix Removing known SSH key entries from ssh-agent (if running)..."
if ssh-add -l &>/dev/null; then
  ssh-add -D || true
fi

echo "$prefix SSH identity banishment complete."
