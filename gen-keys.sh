#!/usr/bin/env bash
set -euo pipefail

# --- CONFIGURATION ---
# Default SSH key path
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
# ----------------------

# 1) Get user info
read -rp "Your full name: " NAME
read -rp "Your email address: " EMAIL

# 2) Ask for optional GPG passphrase
read -rsp "Enter GPG passphrase (leave blank for no passphrase): " GPG_PASSPHRASE
echo

# 3) Build a GPG batch file
GPG_BATCH_FILE="$(mktemp)"
{
  if [[ -z "$GPG_PASSPHRASE" ]]; then
    echo "%no-protection"
  else
    echo "Passphrase: $GPG_PASSPHRASE"
  fi
  cat <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $NAME
Name-Email: $EMAIL
Expire-Date: 0
%commit
EOF
} > "$GPG_BATCH_FILE"

echo "Generating GPG key…"
gpg --batch --generate-key "$GPG_BATCH_FILE"

# 4) Extract the new key’s fingerprint
FPR=$(gpg --with-colons --list-keys "$EMAIL" \
     | awk -F: '/^fpr:/ { print $10; exit }')

# 5) Export and print the ASCII-armored public key
echo
echo "----- BEGIN GPG PUBLIC KEY -----"
gpg --armor --export "$FPR"
echo "-----  END GPG PUBLIC KEY  -----"
echo

# 6) Ask for optional SSH passphrase
read -rsp "Enter SSH key passphrase (leave blank for no passphrase): " SSH_PASSPHRASE
echo

# 7) Generate SSH key if not exists
if [[ -f "$SSH_KEY_PATH" ]]; then
  echo "Warning: SSH key $SSH_KEY_PATH already exists—skipping generation."
else
  echo "Generating SSH Ed25519 key at $SSH_KEY_PATH…"
  ssh-keygen -t ed25519 -a 100 -C "$EMAIL" -f "$SSH_KEY_PATH" -N "$SSH_PASSPHRASE"
fi

# 8) Print SSH public key
echo
echo "SSH public key (paste this into GitLab/GitHub):"
cat "${SSH_KEY_PATH}.pub"
echo

# 9) Cleanup
rm -f "$GPG_BATCH_FILE"
