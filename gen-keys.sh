#!/usr/bin/env bash
set -euo pipefail

# --- CONFIGURATION ---
# Change these defaults if you like:
GPG_BATCH_FILE="$(mktemp)"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
# ----------------------

# 1) Get user info
read -rp "Your full name: " NAME
read -rp "Your email address: " EMAIL

# 2) Create GPG batch parameters
cat >"$GPG_BATCH_FILE" <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $NAME
Name-Email: $EMAIL
Expire-Date: 0
%commit
EOF

echo "Generating GPG key (this may take a minute)..."
gpg --batch --generate-key "$GPG_BATCH_FILE"

# 3) Extract the new key’s fingerprint
FPR=$(gpg --with-colons --list-keys "$EMAIL" \
     | awk -F: '/^fpr:/ { print $10; exit }')

# 4) Export ASCII-armored public key
echo
echo "----- BEGIN GPG PUBLIC KEY -----"
gpg --armor --export "$FPR"
echo "-----  END GPG PUBLIC KEY  -----"
echo

# 5) Generate SSH key (Ed25519) with empty passphrase
if [[ -f "$SSH_KEY_PATH" ]]; then
  echo "Warning: SSH key $SSH_KEY_PATH already exists—skipping generation."
else
  echo "Generating SSH Ed25519 key at $SSH_KEY_PATH..."
  ssh-keygen -t ed25519 -a 100 -C "$EMAIL" -f "$SSH_KEY_PATH" -N ""
fi

# 6) Output SSH public key
echo
echo "SSH public key (paste this into GitLab/GitHub):"
cat "${SSH_KEY_PATH}.pub"
echo

# 7) Cleanup
rm -f "$GPG_BATCH_FILE"
