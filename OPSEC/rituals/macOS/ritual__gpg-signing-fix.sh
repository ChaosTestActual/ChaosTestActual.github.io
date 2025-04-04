#!/bin/bash
set -euo pipefail

prefix="RITUAL: GPG SIGNING FIX: "

echo "$prefix __INITIATED__."

echo "$prefix Setting GPG_TTY..."
export GPG_TTY=$(tty)

echo "$prefix Configuring loopback pinentry..."
echo "use-agent
pinentry-mode loopback" >> ~/.gnupg/gpg.conf
echo "allow-loopback-pinentry" >> ~/.gnupg/gpg-agent.conf

echo "$prefix Restarting GPG agent..."
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

if [[ $# -eq 1 ]]; then
  key="$1"
  echo "$prefix Setting Git to use signing key: $key"
  git config --global user.signingkey "$key"
  git config --global gpg.program "$(which gpg)"
fi

echo "$prefix __COMPLETE__."
