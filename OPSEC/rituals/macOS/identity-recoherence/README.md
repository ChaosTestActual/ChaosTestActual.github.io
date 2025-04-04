# macOS Identity Provisioning Rituals

This folder contains modular provisioning scripts for secure GPG + YubiKey setup under macOS.  
Each script performs a focused, idempotent step in the identity consecration process.

---

## 🧱 Modular Scripts

| Script | Description |
|--------|-------------|
| `ritual__install-prereqs.sh` | Installs Homebrew (if needed) and required packages: `gnupg`, `pinentry-mac`, `ykman`, `yubikey-agent`, `libfido2`. |
| `ritual__configure-gpg-env.sh` | Sets up GPG agent configuration and SSH support. |
| `ritual__select-key-colors.sh` | Prompts user to label their YubiKeys (e.g. “Blue”, “Green”). Stores choices temporarily. |
| `ritual__provision-key.sh` | Handles GPG key generation and subkey transfers across multiple YubiKeys. |
| `ritual__configure-git-and-ssh.sh` | Sets Git config (noreply email, GPG signing key), copies SSH pubkey to clipboard. |
| `ritual__finalize-and-export.sh` | Cleans up private key exports, copies relevant info to clipboard, and reminds user to upload keys. |
| `ritual__gpg-signing-fix.sh` | Patches Git + GPG signing issues (TTY, loopback pinentry). |
| `ritual__provision-all-keys.sh` | Orchestrates the above scripts in the correct order. |

---

## 🚀 Usage

To execute the full provisioning sequence:

```bash
sh ./ritual__provision-all-keys.sh