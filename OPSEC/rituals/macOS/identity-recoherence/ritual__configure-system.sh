#!/bin/bash
set -euo pipefail

prefix="RITUAL: CONFIGURE SYSTEM: "

echo "$prefix __INITIATED__."

# GPG: Ensure ~/.gnupg exists and is secure
echo "$prefix Setting up GPG environment..."
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg

cat > ~/.gnupg/gpg-agent.conf <<EOF
use-standard-socket
enable-ssh-support
pinentry-program /opt/homebrew/bin/pinentry-mac
default-cache-ttl 600
max-cache-ttl 7200
allow-loopback-pinentry
EOF

gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

# SSH_AUTH_SOCK in shell profile
if ! grep -q 'SSH_AUTH_SOCK' ~/.zshrc; then
  echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >> ~/.zshrc
  echo "$prefix Added SSH_AUTH_SOCK to ~/.zshrc"
fi

# Git: Configure identity and GPG signing
echo "$prefix Configuring Git identity..."
git config --global user.name "ChaosTestActual"
git config --global user.email "205630590+ChaosTestActual@users.noreply.github.com"

echo "$prefix Setting Git to sign commits by default..."
git config --global commit.gpgsign true
git config --global gpg.program "$(which gpg)"

# Optional: copy SSH public key if it exists
if [[ -f ~/.ssh/id_ed25519.pub ]]; then
  pbcopy < ~/.ssh/id_ed25519.pub
  echo "$prefix Copied SSH public key to clipboard."
else
  echo "$prefix No SSH key found at ~/.ssh/id_ed25519.pub"
fi

# Set GPG_TTY for current session
echo "$prefix Setting GPG_TTY..."
export GPG_TTY=$(tty)

echo "$prefix __COMPLETE__."
