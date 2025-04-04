#!/bin/bash

set -euo pipefail

KEY_EMAIL="205630590+ChaosTestActual@users.noreply.github.com"
KEY_NAME="ChaosTestActual"
EXPORT_DIR="$HOME/Documents"
GPG_CONF="$HOME/.gnupg/gpg-agent.conf"
SHELL_RC="$HOME/.zshrc"
SHELL_RC="${SHELL_RC:-$HOME/.zshrc}"
AVAILABLE_COLORS=("Blue" "Green" "Red" "Black" "White" "Purple" "Orange" "Yellow")

echo "🔧 Installing required tools..."
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install ykman gnupg pinentry-mac libfido2 yubikey-agent

echo "🧭 Configuring GPG environment..."
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
echo "enable-ssh-support" >> "$GPG_CONF"
echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >> "$GPG_CONF"

echo "📝 Checking for SSH_AUTH_SOCK config in $SHELL_RC..."
if ! grep -q "SSH_AUTH_SOCK" "$SHELL_RC"; then
  echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >> "$SHELL_RC"
  echo "source $SHELL_RC" >> "$SHELL_RC"
fi

source "$SHELL_RC"
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

echo "🔐 Enter an 8-digit or longer User PIN:"
read -rs USER_PIN
while [[ ${#USER_PIN} -lt 8 ]]; do
  echo "❌ PIN must be at least 8 digits. Try again:"
  read -rs USER_PIN
done

echo "Paste .env content (or press ENTER to skip and generate values automagically):"
read -r ENV_INPUT
if [[ -n "$ENV_INPUT" ]]; then
  echo "$ENV_INPUT" > /tmp/.yubikey.env
  source /tmp/.yubikey.env
  echo "Loaded variables from pasted input."
else
  echo "No .env content provided. Will prompt for values interactively."
fi

declare -a SELECTED_COLORS
declare -a SELECTED_COLOR_INDEXES=()

echo "🌈 How many YubiKeys are you provisioning? [2-8] (default: 2)"
read -r NUM_KEYS
NUM_KEYS=${NUM_KEYS:-2}

if ! [[ "$NUM_KEYS" =~ ^[2-8]$ ]]; then
  echo "❌ Invalid number of keys. Must be between 2 and 8."
  exit 1
fi

for (( i=1; i<=NUM_KEYS; i++ )); do
  DEFAULT_COLOR_INDEX=0

  if [[ $i -eq 1 ]]; then
    DEFAULT_COLOR_INDEX=1 # Blue
  elif [[ $i -eq 2 && "${SELECTED_COLORS[0]}" == "Green" ]]; then
    DEFAULT_COLOR_INDEX=1 # Blue
  elif [[ $i -eq 2 ]]; then
    DEFAULT_COLOR_INDEX=2 # Green
  fi

  while true; do
    AVAILABLE_COLOR_INDEXES=()
    for (( j=1; j<=${#AVAILABLE_COLORS[@]}; j++ )); do
      SKIP=false
      for USED in "${SELECTED_COLOR_INDEXES[@]+"${SELECTED_COLOR_INDEXES[@]}"}"; do
        if [[ $USED -eq $j ]]; then
          SKIP=true
          break
        fi
      done
      if ! $SKIP; then
        AVAILABLE_COLOR_INDEXES+=($j)
      fi
    done

    echo ""
    echo "Available colors:"
    for (( j=1; j<=${#AVAILABLE_COLORS[@]}; j++ )); do
      COLOR="${AVAILABLE_COLORS[$((j - 1))]}"
      if [[ "${SELECTED_COLOR_INDEXES[@]+"${SELECTED_COLOR_INDEXES[@]}"}" =~ (^|[[:space:]])$j($|[[:space:]]) ]]; then
        echo -e "  $j) \033[90m$COLOR (already selected)\033[0m"
      else
        echo "  $j) $COLOR"
      fi
    done

    if [[ $DEFAULT_COLOR_INDEX -eq 0 ]]; then
      echo -n "🎨 Select a color index for YubiKey #$i (required): "
    else
      DEFAULT_COLOR="${AVAILABLE_COLORS[$((DEFAULT_COLOR_INDEX - 1))]}"
      echo -n "🎨 Select a color index for YubiKey #$i (default: $DEFAULT_COLOR_INDEX = $DEFAULT_COLOR): "
    fi

    read -r COLOR_INDEX
    if [[ -z "$COLOR_INDEX" && $DEFAULT_COLOR_INDEX -ne 0 ]]; then
      COLOR_INDEX="$DEFAULT_COLOR_INDEX"
    fi

    if [[ ! " ${AVAILABLE_COLOR_INDEXES[*]} " =~ " $COLOR_INDEX " ]]; then
      echo "❌ Invalid selection. Try again."
      continue
    fi

    COLOR="${AVAILABLE_COLORS[$((COLOR_INDEX - 1))]}"
    if [[ $COLOR_INDEX -eq $DEFAULT_COLOR_INDEX ]]; then
      echo "➡️ Using default: $COLOR"
    else
      echo "➡️ You selected: $COLOR"
    fi

    SELECTED_COLOR_INDEXES+=($COLOR_INDEX)
    SELECTED_COLORS+=("$COLOR")
    break
  done
done

for COLOR in "${SELECTED_COLORS[@]}"; do
  while true; do
    echo "🔁 Please insert the ${COLOR} YubiKey. Press ENTER when ready."
    read
    
    ADMIN_PIN=$(gpg --gen-random --armor 2 32 | tr -d '\n')
    RESET_CODE=$(gpg --gen-random --armor 2 24 | tr -d '\n' | sed 's/[^a-zA-Z0-9]/-/g')

    if ! {
      ykman config usb --enable OTP &&
      ykman config usb --enable FIDO2 &&
      ykman config usb --enable OPENPGP &&
      ykman openpgp reset --force &&
      echo "🔐 Admin PIN (to paste when prompted): $ADMIN_PIN" &&
      echo "🧯 Reset Code (to paste when prompted): $RESET_CODE" &&
      echo "▶️ Launching manual PIN setup..." &&
      ykman openpgp access change-pin &&
      ykman openpgp access change-admin-pin &&
      ykman openpgp access change-reset-code
    }; then
      echo "⚠️  Initialization failed for ${COLOR} key. Let's try again..."
      continue
    fi

    if [[ "$COLOR" == "${SELECTED_COLORS[0]}" ]]; then
      echo "🔐 Generating GPG key locally..."

      cat > genkey_batch <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: $KEY_NAME
Name-Email: $KEY_EMAIL
Expire-Date: 2y
%commit
%echo done
EOF

      gpg --batch --generate-key genkey_batch
      rm -f genkey_batch

      # Add subkeys manually
      gpg --batch --yes --edit-key "$KEY_EMAIL" <<EOF
addkey
4
4096
2y
addkey
6
4096
2y
addkey
8
4096
2y
save
EOF

      echo "🔎 Verifying GPG key structure..."
      gpg --list-keys "$KEY_EMAIL"
      gpg --list-secret-keys "$KEY_EMAIL"

      echo "📤 Exporting public and secret keys..."
      gpg --armor --export $KEY_EMAIL > "$EXPORT_DIR/pgp_pubkey.asc"
      gpg --export-secret-keys $KEY_EMAIL > "$EXPORT_DIR/private.key"
      gpg --export-secret-subkeys $KEY_EMAIL > "$EXPORT_DIR/subkeys.key"
    else
      echo "🔄 Moving subkeys to ${COLOR} YubiKey..."
      gpg --batch --yes --edit-key "$KEY_EMAIL" <<EOF
toggle
key 1
keytocard
1
key 2
keytocard
2
key 3
keytocard
3
save
EOF
    fi

    echo "✅ ${COLOR} YubiKey successfully initialized."
    break
  done
done

echo "📋 Adding SSH key to clipboard..."
gpg --export-ssh-key $KEY_EMAIL | pbcopy

echo "📝 Configuring Git to use SSH key for commit signing..."
SSH_KEY_BLOB=$(gpg --export-ssh-key "$KEY_EMAIL" | awk '{print $2}')
git config --global user.name "$KEY_NAME"
git config --global user.email "$KEY_EMAIL"
git config --global gpg.format ssh
git config --global user.signingkey "$SSH_KEY_BLOB"
git config --global commit.gpgsign true

echo "🧼 Removing exported private keys from disk..."
rm -f "$EXPORT_DIR/private.key" "$EXPORT_DIR/subkeys.key"

echo "🛡️ Enforcing exclusive use of YubiKey-backed SSH keys in ~/.ssh/config..."

SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"

cat > "$SSH_CONFIG" <<EOF
Host *
  IdentityAgent $(gpgconf --list-dirs agent-ssh-socket)
  IdentitiesOnly yes
EOF

echo "✅ ~/.ssh/config overwritten with YubiKey-only configuration."

echo "🔁 Ensuring GPG SSH agent is active and shell configured..."

gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

echo "Checking for SSH_AUTH_SOCK config in $SHELL_RC..."
if [ -f "$SHELL_RC" ] && ! grep -q "SSH_AUTH_SOCK" "$SHELL_RC"; then
  echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >> "$SHELL_RC"
  echo "source $SHELL_RC" >> "$SHELL_RC"
  echo "Updated $SHELL_RC with SSH_AUTH_SOCK and source command."
else
  echo "SSH_AUTH_SOCK already configured or $SHELL_RC does not exist."
fi

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

echo "🧾 Exporting generated credentials for Proton Pass..."
CLIP_CONTENT=""
for COLOR in "${SELECTED_COLORS[@]}"; do
  CLIP_CONTENT+="${COLOR}_ADMIN_PIN=${ADMIN_PIN}"$'\n'
  CLIP_CONTENT+="${COLOR}_RESET_CODE=\"${RESET_CODE}\""$'\n\n'
done
echo "$CLIP_CONTENT" | pbcopy
echo "📝 Admin PINs and reset codes copied to clipboard. Paste them into Proton Pass Secure Note now."

echo "✅ Configuration complete."
echo "🔐 Your SSH public key has been copied to the clipboard. Add it to GitHub: https://github.com/settings/keys"