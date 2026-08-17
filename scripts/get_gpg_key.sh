#!/usr/bin/env bash
set -e

# Parse JSON input from stdin (Terraform external data source sends JSON)
eval "$(jq -r '@sh "KEY_ID=\(.key_id // "") MANUAL_KEY=\(.manual_key // "") PASSPHRASE=\(.passphrase // "")"')"

# If manual key was provided, use it directly
if [ -n "$MANUAL_KEY" ]; then
  jq -n --arg key "$MANUAL_KEY" '{"key": $key}'
  exit 0
fi

# If KEY_ID is not provided, detect the first secret key on the system
if [ -z "$KEY_ID" ]; then
  KEY_ID=$(gpg --list-secret-keys --with-colons 2>/dev/null | awk -F: '/^sec/{print $5}' | head -n 1)
fi

if [ -z "$KEY_ID" ]; then
  echo "{\"error\": \"No GPG secret key found on system\"}" >&2
  exit 1
fi

# Export ASCII-armored private key
if [ -n "$PASSPHRASE" ]; then
  EXPORTED_KEY=$(gpg --batch --yes --pinentry-mode loopback --passphrase "$PASSPHRASE" --armor --export-secret-keys "$KEY_ID" 2>/dev/null)
else
  EXPORTED_KEY=$(gpg --batch --yes --armor --export-secret-keys "$KEY_ID" 2>/dev/null)
fi

if [ -z "$EXPORTED_KEY" ]; then
  echo "{\"error\": \"Failed to export GPG secret key for $KEY_ID\"}" >&2
  exit 1
fi

jq -n \
  --arg key "$EXPORTED_KEY" \
  --arg key_id "$KEY_ID" \
  '{"key": $key, "key_id": $key_id}'
