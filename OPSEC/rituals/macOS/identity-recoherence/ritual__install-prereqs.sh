#!/bin/bash
set -euo pipefail

prefix="RITUAL: INSTALL PREREQUISITES: "

echo "$prefix __INITIATED__."

if ! command -v brew >/dev/null 2>&1; then
  echo "$prefix Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "$prefix Homebrew already installed."
fi

echo "$prefix Updating brew..."
brew update

echo "$prefix Installing dependencies..."
brew install gnupg pinentry-mac ykman yubikey-agent libfido2

echo "$prefix Verifying installed tools..."
for tool in gpg pinentry-mac ykman yubikey-agent; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "$prefix ERROR: $tool failed to install or is missing from PATH."
    exit 1
  fi
done

echo "$prefix __COMPLETE__."